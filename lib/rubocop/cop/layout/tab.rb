# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Layout
      # This cop checks for tabs inside the source code.
      #
      # @example
      #   # bad
      #   # This example uses a tab to indent bar.
      #   def foo
      #     bar
      #   end
      #
      #   # good
      #   # This example uses spaces to indent bar.
      #   def foo
      #     bar
      #   end
      #
      class Tab < Cop
        include Alignment
        include RangeHelp

        MSG = 'Tab detected.'

        def investigate(processed_source)
          str_ranges = string_literal_ranges(processed_source.ast)

          processed_source.lines.each.with_index(1) do |line, lineno|
            match = line.match(/^([^\t]*)\t+/)
            next unless match

            prefix = match.captures[0]
            col = prefix.length
            next if in_string_literal?(str_ranges, lineno, col)

            range = source_range(processed_source.buffer,
                                 lineno,
                                 col...match.end(0))

            add_offense(range, location: range)
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            spaces = ' ' * configured_indentation_width
            corrector.replace(range, range.source.gsub(/\t/, spaces))
          end
        end

        private

        # rubocop:disable Metrics/CyclomaticComplexity
        def in_string_literal?(ranges, line, col)
          ranges.any? do |range|
            (range.line == line && range.column <= col) ||
              (range.line < line && line < range.last_line) ||
              (range.line != line && range.last_line == line &&
               range.last_column >= col)
          end
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def string_literal_ranges(ast)
          # which lines start inside a string literal?
          return [] if ast.nil?

          ast.each_node(:str, :dstr).each_with_object(Set.new) do |str, ranges|
            loc = str.location

            range = if str.heredoc?
                      loc.heredoc_body
                    else
                      loc.expression
                    end

            ranges << range
          end
        end
      end
    end
  end
end
