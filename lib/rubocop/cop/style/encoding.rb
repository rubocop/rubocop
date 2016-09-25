# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether the source file has a utf-8 encoding
      # comment or not.
      # Setting this check to "always" and "when_needed" makes sense only
      # for code that should support Ruby 1.9, since in 2.0+ utf-8 is the
      # default source file encoding. There are three styles:
      #
      # when_needed - only enforce an encoding comment if there are non ASCII
      #               characters, otherwise report an offense
      # always - enforce encoding comment in all files
      # never - enforce no encoding comment in all files
      class Encoding < Cop
        include ConfigurableEnforcedStyle

        MSG_MISSING = 'Missing utf-8 encoding comment.'.freeze
        MSG_UNNECESSARY = 'Unnecessary utf-8 encoding comment.'.freeze
        ENCODING_PATTERN = /#.*coding\s?[:=]\s?(?:UTF|utf)-8/
        AUTO_CORRECT_ENCODING_COMMENT = 'AutoCorrectEncodingComment'.freeze
        SHEBANG = '#!'.freeze

        def investigate(processed_source)
          return if processed_source.buffer.source.empty?

          line_number = encoding_line_number(processed_source)
          return unless (@message = offense(processed_source, line_number))

          range = processed_source.buffer.line_range(line_number + 1)
          add_offense(range, range, @message)
        end

        def autocorrect(range)
          if @message == MSG_MISSING
            raise encoding_mismatch_message unless matching_encoding?

            lambda do |corrector|
              corrector.insert_before(range, "#{encoding}\n")
            end
          else
            # Need to remove unnecessary encoding comment
            lambda do |corrector|
              corrector.remove(range_with_surrounding_space(range, :right))
            end
          end
        end

        private

        def encoding
          cop_config[AUTO_CORRECT_ENCODING_COMMENT]
        end

        def matching_encoding?
          encoding =~ ENCODING_PATTERN
        end

        def encoding_mismatch_message
          "#{encoding} does not match #{ENCODING_PATTERN}"
        end

        def offense(processed_source, line_number)
          line = processed_source[line_number]

          if !encoding_present?(line) && !encoding_omitable?
            MSG_MISSING
          elsif encoding_present?(line) && encoding_omitable?
            MSG_UNNECESSARY
          end
        end

        def encoding_present?(line)
          line =~ ENCODING_PATTERN
        end

        def encoding_omitable?
          return true if style == :never

          style != :always && processed_source.buffer.source.ascii_only?
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
