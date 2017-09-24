# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks ensures source files have no utf-8 encoding comments.
      class Encoding < Cop
        MSG_UNNECESSARY = 'Unnecessary utf-8 encoding comment.'.freeze
        ENCODING_PATTERN = /#.*coding\s?[:=]\s?(?:UTF|utf)-8/
        SHEBANG = '#!'.freeze

        def investigate(processed_source)
          return if processed_source.buffer.source.empty?

          line_number = encoding_line_number(processed_source)
          return unless (@message = offense(processed_source, line_number))

          range = processed_source.buffer.line_range(line_number + 1)
          add_offense(range, location: range, message: @message)
        end

        def autocorrect(range)
          lambda do |corrector|
            corrector.remove(range_with_surrounding_space(range, :right))
          end
        end

        private

        def offense(processed_source, line_number)
          line = processed_source[line_number]

          MSG_UNNECESSARY if encoding_omitable?(line)
        end

        def encoding_omitable?(line)
          line =~ ENCODING_PATTERN
        end

        def encoding_line_number(processed_source)
          line_number = 0
          line_number += 1 if processed_source[line_number].start_with?(SHEBANG)
          line_number
        end
      end
    end
  end
end
