# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for a newline after the final magic comment.
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
      class EmptyLineAfterMagicComment < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Add an empty line after magic comments.'

        def on_new_investigation
          return unless processed_source.ast &&
                        (last_magic_comment = last_magic_comment(processed_source))
          return if processed_source[last_magic_comment.loc.line].strip.empty?

          offending_range = offending_range(last_magic_comment)

          add_offense(offending_range) do |corrector|
            corrector.insert_before(offending_range, "\n")
          end
        end

        private

        def offending_range(last_magic_comment)
          source_range(processed_source.buffer, last_magic_comment.loc.line + 1, 0)
        end

        # Find the last magic comment in the source file.
        #
        # Take all comments that precede the first line of code, select the
        # magic comments, and return the last magic comment in the file.
        #
        # @return [Parser::Source::Comment] if magic comments exist before code
        # @return [nil] otherwise
        def last_magic_comment(source)
          source
            .comments
            .take_while { |comment| comment.loc.line < source.ast.loc.line }
            .reverse
            .find { |comment| MagicComment.parse(comment.text).any? }
        end
      end
    end
  end
end
