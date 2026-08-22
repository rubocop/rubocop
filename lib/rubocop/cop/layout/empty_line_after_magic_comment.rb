# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a newline after the final magic comment.
      #
      # The number of empty lines can be configured with `RequiredBlankLines`. Set it to `2`
      # when using YARD, which otherwise treats the magic comments as documentation for the
      # first module or class in the file.
      #
      # @example
      #   # good
      #   # frozen_string_literal: true
      #
      #   # Some documentation for Person
      #   class Person
      #     # Some code
      #   end
      #
      #   # bad
      #   # frozen_string_literal: true
      #   # Some documentation for Person
      #   class Person
      #     # Some code
      #   end
      #
      # @example RequiredBlankLines: 1 (default)
      #   # good
      #   # frozen_string_literal: true
      #
      #   class Person
      #   end
      #
      # @example RequiredBlankLines: 2
      #   # good
      #   # frozen_string_literal: true
      #
      #
      #   class Person
      #   end
      class EmptyLineAfterMagicComment < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Add an empty line after magic comments.'
        MSG_MULTIPLE = 'Add %<required>d empty lines after magic comments.'

        def on_new_investigation
          return unless (last_magic_comment = last_magic_comment(processed_source))

          actual = blank_lines_after(last_magic_comment)
          # Trailing blank lines are `Layout/TrailingEmptyLines`' responsibility.
          return unless processed_source[last_magic_comment.loc.line + actual]
          return if actual == required_blank_lines

          offending_range = offending_range(last_magic_comment, actual)

          add_offense(offending_range, message: message) do |corrector|
            autocorrect(corrector, offending_range, actual)
          end
        end

        private

        def autocorrect(corrector, offending_range, actual)
          if actual < required_blank_lines
            corrector.insert_before(offending_range, "\n" * (required_blank_lines - actual))
          else
            corrector.remove(offending_range)
          end
        end

        def message
          if required_blank_lines == 1
            MSG
          else
            format(MSG_MULTIPLE, required: required_blank_lines)
          end
        end

        def blank_lines_after(last_magic_comment)
          first_line = last_magic_comment.loc.line
          count = 0
          count += 1 while (line = processed_source[first_line + count]) && line.strip.empty?
          count
        end

        def offending_range(last_magic_comment, actual)
          first_blank_line = last_magic_comment.loc.line + 1
          return source_range(processed_source.buffer, first_blank_line, 0) if
            actual < required_blank_lines

          surplus_range(first_blank_line + required_blank_lines, first_blank_line + actual - 1)
        end

        def surplus_range(first_line, last_line)
          buffer = processed_source.buffer
          # Take the terminating newline too, unless the file ends without one.
          end_pos = [buffer.line_range(last_line).end_pos + 1, buffer.source.length].min

          range_between(buffer.line_range(first_line).begin_pos, end_pos)
        end

        def required_blank_lines
          cop_config.fetch('RequiredBlankLines', 1)
        end

        # Find the last magic comment in the source file.
        #
        # Take all comments that precede the first line of code (or just take
        # them all in the case when there is no code), select the
        # magic comments, and return the last magic comment in the file.
        #
        # @return [Parser::Source::Comment] if magic comments exist before code
        # @return [nil] otherwise
        def last_magic_comment(source)
          comments_before_code(source)
            .reverse
            .find { |comment| MagicComment.parse(comment.text).any? }
        end

        def comments_before_code(source)
          if source.ast
            source.comments.take_while { |comment| comment.loc.line < source.ast.loc.line }
          else
            source.comments
          end
        end
      end
    end
  end
end
