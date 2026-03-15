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

        def correct(corrector, processed_source, node, column_delta, &block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
          return unless node

          @processed_source = processed_source

          expr = node.respond_to?(:loc) ? node.source_range : node
          return if block_comment_in_scope?(node)

          taboo_ranges = inside_string_ranges(node)

          if block
            each_line(expr) do |line_begin_pos, line_content|
              line_delta = yield line_begin_pos, line_content
              next if line_delta.zero?

              line_delta /= configured_indentation_width if using_tabs?
              autocorrect_line(corrector, line_begin_pos, expr, line_delta, taboo_ranges)
            end
          else
            # Callers pass column_delta in display columns. For tabs, each tab =
            # configured_indentation_width columns, so convert to character count.
            column_delta /= configured_indentation_width if using_tabs?

            if using_tabs? && column_delta.negative?
              # Only correct the first line for tab removal; nested offenses are
              # corrected separately. Avoids wrong per-line deltas for structures
              # with 'end' keywords.
              first_line_pos = expr.source_buffer.line_range(expr.line).begin_pos
              autocorrect_line(corrector, first_line_pos, expr, column_delta, taboo_ranges)
            else
              each_line(expr) do |line_begin_pos, _line_content|
                autocorrect_line(corrector, line_begin_pos, expr, column_delta, taboo_ranges)
              end
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
            corrector.insert_before(range, indent_char * column_delta)
          elsif /\A[ \t]+\z/.match?(range.source)
            corrector.remove(range)
          end
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

        # Skip correction if the node or any ancestor contains a block comment.
        # This avoids correcting indentation inside scopes that have =begin..=end.
        def block_comment_in_scope?(node)
          return false unless node.is_a?(Parser::AST::Node)

          nodes_to_check = [node]
          nodes_to_check.concat(node.ancestors.to_a)
          nodes_to_check.any? do |n|
            next false unless n.respond_to?(:source_range)

            range = n.source_range
            processed_source.comments.select(&:document?).any? do |c|
              within?(c.source_range, range)
            end
          end
        end

        def calculate_range(expr, line_begin_pos, column_delta) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          return range_between(line_begin_pos, line_begin_pos) if column_delta.positive?

          if using_tabs?
            # For tab removal, target leading whitespace at line start
            line_start = expr.source_buffer.line_range(
              expr.source_buffer.line_for_position(line_begin_pos)
            ).begin_pos
            chars_to_remove = column_delta.abs
            source = expr.source_buffer.source
            line_end = source.index("\n", line_start) || source.length
            leading = source[line_start...line_end][/\A[ \t]*/]
            chars_to_remove = [chars_to_remove, leading.length].min
            return range_between(line_start, line_start) if chars_to_remove.zero?

            range_between(line_start, line_start + chars_to_remove)
          else
            # Original logic for spaces
            starts_with_space = expr.source_buffer.source[line_begin_pos].start_with?(' ')
            if starts_with_space
              range_between(line_begin_pos, line_begin_pos + column_delta.abs)
            else
              range_between(line_begin_pos - column_delta.abs, line_begin_pos)
            end
          end
        end

        def configured_indentation_width
          processed_source.config.for_cop('Layout/IndentationStyle')['IndentationWidth'] ||
            processed_source.config.for_cop('Layout/IndentationWidth')['Width'] || 2
        end

        def indent_width
          return 1 if using_tabs?

          processed_source.config.for_cop('Layout/IndentationWidth')['Width'] || 2
        end

        def indent_char
          using_tabs? ? "\t" : ' '
        end

        def each_line(expr)
          line_begin_pos = expr.begin_pos
          expr.source.each_line do |line|
            yield line_begin_pos, line
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
