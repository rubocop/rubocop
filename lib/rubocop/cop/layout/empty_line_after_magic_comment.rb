# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a newline after the final magic comment.
      #
      # `NumberOfEmptyLines` configures the minimum number of empty lines required. Set it
      # to `2` when using YARD, which otherwise treats the magic comments as documentation
      # for the first module or class in the file.
      #
      # NOTE: `Layout/EmptyLines` has to be disabled for values greater than `1`, as it
      # removes the extra empty lines this cop adds, and autocorrecting with both enabled
      # loops between them.
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
      # @example NumberOfEmptyLines: 1 (default)
      #   # good
      #   # frozen_string_literal: true
      #
      #   class Person
      #   end
      #
      # @example NumberOfEmptyLines: 2
      #   # bad
      #   # frozen_string_literal: true
      #
      #   class Person
      #   end
      #
      #   # good
      #   # frozen_string_literal: true
      #
      #
      #   class Person
      #   end
      class EmptyLineAfterMagicComment < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Expected at least %<expected>d empty %<lines>s after magic comments; found ' \
              '%<actual>d.'

        def validate_config
          return if number_of_empty_lines.is_a?(Integer) && number_of_empty_lines.positive?

          raise ValidationError,
                'The `Layout/EmptyLineAfterMagicComment` cop only accepts a positive ' \
                'integer for its `NumberOfEmptyLines` configuration parameter, but ' \
                "`#{number_of_empty_lines.inspect}` was given."
        end

        def on_new_investigation
          return unless (last_magic_comment = last_magic_comment(processed_source))

          actual = empty_lines_after(last_magic_comment)
          # Trailing empty lines are `Layout/TrailingEmptyLines`' responsibility.
          return unless processed_source[last_magic_comment.loc.line + actual]
          return if actual >= number_of_empty_lines

          offending_range = offending_range(last_magic_comment)

          add_offense(offending_range, message: message(actual)) do |corrector|
            corrector.insert_before(offending_range, "\n" * (number_of_empty_lines - actual))
          end
        end

        private

        def message(actual)
          format(MSG, expected: number_of_empty_lines, actual: actual,
                      lines: number_of_empty_lines == 1 ? 'line' : 'lines')
        end

        def empty_lines_after(last_magic_comment)
          first_line = last_magic_comment.loc.line
          count = 0
          count += 1 while (line = processed_source[first_line + count]) && line.strip.empty?
          count
        end

        def offending_range(last_magic_comment)
          source_range(processed_source.buffer, last_magic_comment.loc.line + 1, 0)
        end

        def number_of_empty_lines
          cop_config.fetch('NumberOfEmptyLines', 1)
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
