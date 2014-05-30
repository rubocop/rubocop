# encoding: utf-8

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

          whitespace_at_end = sb.source[/\s*\Z/]
          blank_lines = whitespace_at_end.count("\n") - 1
          wanted_blank_lines = style == :final_newline ? 0 : 1

          return unless blank_lines != wanted_blank_lines

          begin_pos = sb.source.length - whitespace_at_end.length
          autocorrect_range = Parser::Source::Range.new(sb, begin_pos,
                                                        sb.source.length)
          begin_pos += "\n".length unless whitespace_at_end.length == 0
          report_range = Parser::Source::Range.new(sb, begin_pos,
                                                   sb.source.length)
          add_offense(autocorrect_range, report_range,
                      message(wanted_blank_lines, blank_lines))
        end

        private

        def message(wanted_blank_lines, blank_lines)
          case blank_lines
          when -1
            'Final newline missing.'
          when 0
            'Trailing blank line missing.'
          else
            instead_of = if wanted_blank_lines == 0
                           ''
                         else
                           "instead of #{wanted_blank_lines} "
                         end
            format('%d trailing blank lines %sdetected.', blank_lines,
                   instead_of)
          end
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            corrector.replace(range, style == :final_newline ? "\n" : "\n\n")
          end
        end
      end
    end
  end
end
