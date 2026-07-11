# frozen_string_literal: true

module RuboCop
  module Cop
    # This class does autocorrection of nodes that should just be moved to
    # the left or to the right, amount being determined by the instance
    # variable column_delta.
    class AlignmentCorrector
      extend RangeHelp
      extend Alignment

      class << self
        attr_reader :processed_source

        # `tab_indentation` may only be set by callers whose `column_delta` represents
        # whole indentation levels (e.g. `Layout/IndentationWidth`).
        # Alignment to an arbitrary column cannot be expressed with tabs, so those callers
        # leave tab correction disabled to avoid producing a never-converging correction.
        def correct(corrector, processed_source, node, column_delta, tab_indentation: false)
          return unless node

          @processed_source = processed_source

          expr = node.respond_to?(:loc) ? node.source_range : node
          return if block_comment_within?(expr)

          taboo_ranges = inside_string_ranges(node)

          if using_tabs?
            return unless tab_indentation

            correct_tab_indentation(corrector, expr, column_delta, taboo_ranges)
          else
            each_line(expr) do |line_begin_pos|
              autocorrect_line(corrector, line_begin_pos, expr, column_delta, taboo_ranges)
            end
          end
        end

        def align_end(corrector, processed_source, node, align_to)
          @processed_source = processed_source
          whitespace = whitespace_range(node)
          column = alignment_column(align_to)
          indentation = indentation_string(column)

          if whitespace.source.strip.empty?
            corrector.replace(whitespace, indentation)
          else
            corrector.insert_after(whitespace, "\n#{indentation}")
          end
        end

        private

        def autocorrect_line(corrector, line_begin_pos, expr, column_delta,
                             taboo_ranges)
          range = calculate_range(expr, line_begin_pos, column_delta)
          # We must not change indentation of heredoc strings or inside other
          # string literals
          return if taboo_ranges.any? { |t| within?(range, t) }

          if column_delta.positive? && range.resize(1).source != "\n"
            corrector.insert_before(range, ' ' * column_delta)
          elsif /\A[ \t]+\z/.match?(range.source)
            corrector.remove(range)
          end
        end

        # Tab indentation is corrected by rewriting each line's leading whitespace to
        # the target number of tabs. Working in whole tabs rather than applying a column delta
        # keeps the result idempotent, which avoids the infinite loops that delta-based correction
        # caused for tabs.
        def correct_tab_indentation(corrector, expr, column_delta, taboo_ranges)
          buffer = expr.source_buffer

          each_line(expr) do |line_begin_pos|
            line_range = buffer.line_range(buffer.line_for_position(line_begin_pos))
            correct_tab_line(corrector, line_range, column_delta, taboo_ranges)
          end
        end

        def correct_tab_line(corrector, line_range, column_delta, taboo_ranges)
          leading = line_range.source[/\A[ \t]*/]
          return if leading.length == line_range.source.length # blank line

          leading_range = range_between(line_range.begin_pos, line_range.begin_pos + leading.length)
          return if taboo_ranges.any? { |t| within?(leading_range, t) }

          target = target_tab_indentation(leading, column_delta)
          corrector.replace(leading_range, target) unless leading == target
        end

        def target_tab_indentation(leading, column_delta)
          width = configured_indentation_width
          return leading unless width.positive?

          visual_width = leading.chars.sum { |char| char == "\t" ? width : 1 }

          "\t" * ([visual_width + column_delta, 0].max / width)
        end

        # The number of columns a single tab spans. This must match the width
        # `Layout/IndentationWidth` uses to compute `column_delta`, otherwise
        # the division below would not land on a tab boundary. `Layout/IndentationStyle`
        # has its own `IndentationWidth`, but that only governs how that cop replaces tabs
        # with spaces, so it must not be consulted here.
        def configured_indentation_width
          processed_source.config.for_cop('Layout/IndentationWidth')['Width'] || 2
        end

        def inside_string_ranges(node)
          return [] unless node.is_a?(Parser::AST::Node)

          node.each_node(:any_str).filter_map { |n| inside_string_range(n) }
        end

        def inside_string_range(node)
          loc = node.location

          if node.heredoc?
            loc.heredoc_body.join(loc.heredoc_end)
          elsif delimited_string_literal?(node)
            loc.begin.end.join(loc.end.begin)
          end
        end

        # Some special kinds of string literals are not composed of literal
        # characters between two delimiters:
        # - The source map of `?a` responds to :begin and :end but its end is
        #   nil.
        # - The source map of `__FILE__` responds to neither :begin nor :end.
        def delimited_string_literal?(node)
          node.loc?(:begin) && node.loc?(:end)
        end

        def block_comment_within?(expr)
          processed_source.comments.select(&:document?).any? do |c|
            within?(c.source_range, expr)
          end
        end

        def calculate_range(expr, line_begin_pos, column_delta)
          return range_between(line_begin_pos, line_begin_pos) if column_delta.positive?

          starts_with_space = expr.source_buffer.source[line_begin_pos].start_with?(' ')

          if starts_with_space
            range_between(line_begin_pos, line_begin_pos + column_delta.abs)
          else
            range_between(line_begin_pos - column_delta.abs, line_begin_pos)
          end
        end

        def each_line(expr)
          line_begin_pos = expr.begin_pos
          expr.source.each_line do |line|
            yield line_begin_pos
            line_begin_pos += line.length
          end
        end

        def whitespace_range(node)
          begin_pos = node.loc.end.begin_pos

          range_between(begin_pos - node.loc.end.column, begin_pos)
        end

        def alignment_column(align_to)
          if !align_to
            0
          elsif align_to.respond_to?(:loc)
            align_to.source_range.column
          else
            align_to.column
          end
        end

        def indentation_string(column)
          if using_tabs?
            "\t" * column
          else
            ' ' * column
          end
        end

        def using_tabs?
          config = processed_source.config
          indentation_style = config.for_cop('Layout/IndentationStyle')['EnforcedStyle']
          indentation_style == 'tabs'
        end
      end
    end
  end
end
