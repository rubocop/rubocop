# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop looks for trailing blank lines and a final newline in the
      # source code.
      #
      # @example
      #   # bad
      #   class Foo; end
      #
      #   # EOF
      #
      #   # bad
      #   class Foo; end # EOF
      #
      #   # good
      #   class Foo; end
      #   # EOF
      #
      class TrailingBlankLines < Cop
        include RangeHelp

        def investigate(processed_source)
          buffer = processed_source.buffer
          return if buffer.source.empty?

          # The extra text that comes after the last token could be __END__
          # followed by some data to read. If so, we don't check it because
          # there could be good reasons why it needs to end with a certain
          # number of newlines.
          return if ends_in_end?(processed_source)

          whitespace_at_end = buffer.source[/\s*\Z/]
          blank_lines = whitespace_at_end.count("\n") - 1

          return if blank_lines.zero?

          offense_detected(buffer, blank_lines, whitespace_at_end)
        end

        def autocorrect(range)
          lambda do |corrector|
            corrector.replace(range, "\n")
          end
        end

        private

        def offense_detected(buffer, blank_lines, whitespace_at_end)
          begin_pos = buffer.source.length - whitespace_at_end.length
          autocorrect_range = range_between(begin_pos, buffer.source.length)
          begin_pos += 1 unless whitespace_at_end.empty?
          report_range = range_between(begin_pos, buffer.source.length)

          add_offense(autocorrect_range,
                      location: report_range,
                      message: message(blank_lines))
        end

        def ends_in_end?(processed_source)
          buffer = processed_source.buffer

          return true if buffer.source.strip.start_with?('__END__')
          return false if processed_source.tokens.empty?

          extra = buffer.source[processed_source.tokens.last.end_pos..-1]
          extra && extra.strip.start_with?('__END__')
        end

        def message(blank_lines)
          if blank_lines == -1
            'Final newline missing.'
          else
            format('%<blank_lines>d trailing blank lines detected.',
                   blank_lines: blank_lines)
          end
        end
      end
    end
  end
end
