# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Layout
      # This cops checks for two or more consecutive blank lines.
      #
      # @example
      #
      #   # bad - It has two empty lines.
      #   some_method
      #   # one empty line
      #   # two empty lines
      #   some_method
      #
      #   # good
      #   some_method
      #   # one empty line
      #   some_method
      #
      class EmptyLines < Cop
        MSG = 'Extra blank line detected.'.freeze
        LINE_OFFSET = 2

        def investigate(processed_source)
          return if processed_source.tokens.empty?

          lines = Set.new
          processed_source.tokens.each do |token|
            lines << token.pos.line
          end

          each_extra_empty_line(lines.sort) do |range|
            add_offense(range, location: range)
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end

        private

        def each_extra_empty_line(lines)
          prev_line = 1

          lines.each do |cur_line|
            if exceeds_line_offset?(cur_line - prev_line)
              # we need to be wary of comments since they
              # don't show up in the tokens
              ((prev_line + 1)...cur_line).each do |line|
                next unless previous_and_current_lines_empty?(line)

                yield source_range(processed_source.buffer, line, 0)
              end
            end

            prev_line = cur_line
          end
        end

        def exceeds_line_offset?(line_diff)
          line_diff > LINE_OFFSET
        end

        def previous_and_current_lines_empty?(line)
          processed_source[line - 2].empty? && processed_source[line - 1].empty?
        end
      end
    end
  end
end
