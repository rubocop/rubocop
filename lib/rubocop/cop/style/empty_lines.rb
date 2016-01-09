# encoding: utf-8

require 'set'

module RuboCop
  module Cop
    module Style
      # This cops checks for two or more consecutive blank lines.
      class EmptyLines < Cop
        MSG = 'Extra blank line detected.'.freeze
        LINE_OFFSET = 2

        def investigate(processed_source)
          return if processed_source.tokens.empty?

          lines = Set.new
          processed_source.tokens.each do |token|
            lines << token.pos.line
          end

          prev_line = 1

          lines.sort.each do |cur_line|
            line_diff = cur_line - prev_line

            if line_diff > LINE_OFFSET
              # we need to be wary of comments since they
              # don't show up in the tokens
              ((prev_line + 1)...cur_line).each do |line|
                # we check if the prev and current lines are empty
                next unless processed_source[line - 2].empty? &&
                            processed_source[line - 1].empty?

                range = source_range(processed_source.buffer, line, 0)
                add_offense(range, range)
              end
            end

            prev_line = cur_line
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
