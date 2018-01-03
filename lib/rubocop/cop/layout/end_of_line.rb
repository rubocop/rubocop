# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for Windows-style line endings in the source code.
      class EndOfLine < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG_DETECTED = 'Carriage return character detected.'.freeze
        MSG_MISSING = 'Carriage return character missing.'.freeze

        def investigate(processed_source)
          last_token = processed_source.tokens.last
          last_line =
            last_token ? last_token.line : processed_source.lines.length

          processed_source.raw_source.each_line.with_index do |line, index|
            break if index >= last_line
            msg = offense_message(line)
            next unless msg
            next if unimportant_missing_cr?(index, last_line, line)

            range =
              source_range(processed_source.buffer, index + 1, 0, line.length)
            add_offense(nil, location: range, message: msg)
            # Usually there will be carriage return characters on all or none
            # of the lines in a file, so we report only one offense.
            break
          end
        end

        # If there is no LF on the last line, we don't care if there's no CR.
        def unimportant_missing_cr?(index, last_line, line)
          style == :crlf && index == last_line - 1 && line !~ /\n$/
        end

        def offense_message(line)
          effective_style = if style == :native
                              Platform.windows? ? :crlf : :lf
                            else
                              style
                            end
          case effective_style
          when :lf then MSG_DETECTED if line =~ /\r$/
          else MSG_MISSING if line !~ /\r$/
          end
        end
      end
    end
  end
end
