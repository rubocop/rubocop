# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks whether the source file has a utf-8 encoding
      # comment or not. This check makes sense only for code that
      # should support Ruby 1.9, since in 2.0+ utf-8 is the default
      # source file encoding. There are two style:
      #
      # when_needed - only enforce an encoding comment if there are non ASCII
      #               characters, otherwise report an offense
      # always - enforce encoding comment in all files
      class Encoding < Cop
        include ConfigurableEnforcedStyle

        MSG_MISSING = 'Missing utf-8 encoding comment.'
        MSG_UNNECESSARY = 'Unnecessary utf-8 encoding comment.'
        ENCODING_PATTERN = /#.*coding\s?[:=]\s?(?:UTF|utf)-8/

        def investigate(processed_source)
          return if processed_source.buffer.source.empty?

          line_number = encoding_line_number(processed_source)
          message = offense(processed_source, line_number)

          return unless message

          range = source_range(processed_source.buffer, line_number + 1, 0)
          add_offense(processed_source.tokens.first, range, message)
        end

        def autocorrect(node)
          encoding = cop_config['AutoCorrectEncodingComment']
          if encoding && encoding =~ ENCODING_PATTERN
            lambda do |corrector|
              corrector.replace(node.pos, "#{encoding}\n#{node.pos.source}")
            end
          else
            fail "#{encoding} does not match #{ENCODING_PATTERN}"
          end
        end

        private

        def offense(processed_source, line_number)
          line = processed_source[line_number]
          encoding_present = line =~ ENCODING_PATTERN
          ascii_only = processed_source.buffer.source.ascii_only?
          always_encode = style == :always

          if !encoding_present && (always_encode || !ascii_only)
            MSG_MISSING
          elsif !always_encode && ascii_only && encoding_present
            MSG_UNNECESSARY
          end
        end

        def encoding_line_number(processed_source)
          line_number = 0
          line_number += 1 if processed_source[line_number].start_with?('#!')
          line_number
        end
      end
    end
  end
end
