# frozen_string_literal: true

module RuboCop
  module Cop
    # This class does auto-correction of nodes that should just be moved to
    # the left or to the right, amount being determined by the instance
    # variable column_delta.
    class AlignmentCorrector
      extend RangeHelp
      extend Alignment

      class << self
        attr_reader :processed_source

        def correct(processed_source, node, column_delta)
          return unless node

          @processed_source = processed_source
          expr = node.respond_to?(:loc) ? node.loc.expression : node
          return if block_comment_within?(expr)

          lambda do |corrector|
            each_line(expr) do |line_begin_pos|
              autocorrect_line(corrector, line_begin_pos, expr, column_delta,
                               heredoc_ranges(node))
            end
          end
        end

        def align_end(processed_source, node, align_to)
          @processed_source = processed_source
          whitespace = whitespace_range(node)
          return false unless whitespace.source.strip.empty?

          column = alignment_column(align_to)
          ->(corrector) { corrector.replace(whitespace, ' ' * column) }
        end

        private

        def autocorrect_line(corrector, line_begin_pos, expr, column_delta,
                             heredoc_ranges)
          range = calculate_range(expr, line_begin_pos, column_delta)
          # We must not change indentation of heredoc strings.
          return if heredoc_ranges.any? { |h| within?(range, h) }

          if column_delta.positive?
            unless range.source == "\n"
              # TODO: Fix ranges instead of using `begin`
              corrector.insert_before(range.begin, ' ' * column_delta)
            end
          elsif range.source =~ /\A[ \t]+\z/
            remove(range, corrector)
          end
        end

        def heredoc_ranges(node)
          return [] unless node.is_a?(Parser::AST::Node)

          node.each_node(:dstr)
              .select(&:heredoc?)
              .map { |n| n.loc.heredoc_body.join(n.loc.heredoc_end) }
        end

        def block_comment_within?(expr)
          processed_source.comments.select(&:document?).any? do |c|
            within?(c.loc.expression, expr)
          end
        end

        def calculate_range(expr, line_begin_pos, column_delta)
          starts_with_space =
            expr.source_buffer.source[line_begin_pos].start_with?(' ')
          pos_to_remove = if column_delta.positive? || starts_with_space
                            line_begin_pos
                          else
                            line_begin_pos - column_delta.abs
                          end

          range_between(pos_to_remove, pos_to_remove + column_delta.abs)
        end

        def remove(range, corrector)
          original_stderr = $stderr
          $stderr = StringIO.new # Avoid error messages on console
          corrector.remove(range)
        rescue RuntimeError
          range = range_between(range.begin_pos + 1, range.end_pos + 1)
          retry if range.source =~ /^ +$/
        ensure
          $stderr = original_stderr
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
      end
    end
  end
end
