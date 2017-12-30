# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop looks for trailing whitespace in the source code.
      class TrailingWhitespace < Cop
        include RangeHelp

        MSG = 'Trailing whitespace detected.'.freeze

        def investigate(processed_source)
          processed_source.lines.each_with_index do |line, index|
            next unless line.end_with?(' ', "\t")

            range = source_range(processed_source.buffer,
                                 index + 1,
                                 (line.rstrip.length)...(line.length))

            add_offense(range, location: range)
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
