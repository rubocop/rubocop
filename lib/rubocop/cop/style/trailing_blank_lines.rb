# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for trailing blank lines and a final newline in the
      # source code.
      class TrailingBlankLines < Cop
        include ConfigurableEnforcedStyle

        def investigate(processed_source)
          sb = processed_source.buffer
          return if sb.source.empty?

          # The extra text that comes after the last token could be __END__
          # followed by some data to read. If so, we don't check it because
          # there could be good reasons why it needs to end with a certain
          # number of newlines.
          return if ends_in_end?(processed_source)

          whitespace_at_end = sb.source[/\s*\Z/]
          blank_lines = whitespace_at_end.count("\n") - 1
          wanted_blank_lines = style == :final_newline ? 0 : 1

          return unless blank_lines != wanted_blank_lines

          offense_detected(sb, wanted_blank_lines, blank_lines,
                           whitespace_at_end)
        end

        private

        def offense_detected(sb, wanted_blank_lines, blank_lines,
                             whitespace_at_end)
          begin_pos = sb.source.length - whitespace_at_end.length
          autocorrect_range = Parser::Source::Range.new(sb, begin_pos,
                                                        sb.source.length)
          begin_pos += 1 unless whitespace_at_end.empty?
          report_range = Parser::Source::Range.new(sb, begin_pos,
                                                   sb.source.length)
          add_offense(autocorrect_range, report_range,
                      message(wanted_blank_lines, blank_lines))
        end

        def ends_in_end?(processed_source)
          sb = processed_source.buffer

          return true if sb.source.strip.start_with?('__END__')
          return false if processed_source.tokens.empty?

          extra = sb.source[processed_source.tokens.last.pos.end_pos..-1]
          extra && extra.strip.start_with?('__END__')
        end

        def message(wanted_blank_lines, blank_lines)
          case blank_lines
          when -1
            'Final newline missing.'
          when 0
            'Trailing blank line missing.'
          else
            instead_of = if wanted_blank_lines.zero?
                           ''
                         else
                           "instead of #{wanted_blank_lines} "
                         end
            format('%d trailing blank lines %sdetected.', blank_lines,
                   instead_of)
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            corrector.replace(range, style == :final_newline ? "\n" : "\n\n")
          end
        end
      end
    end
  end
end
