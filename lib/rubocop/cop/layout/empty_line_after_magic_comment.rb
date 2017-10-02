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
      class EmptyLineAfterMagicComment < Cop
        MSG = 'Add an empty line after magic comments.'.freeze
        BLANK_LINE = /\A\s*\z/

        def investigate(source)
          return unless source.ast &&
                        (last_magic_comment = last_magic_comment(source))
          return if source[last_magic_comment.loc.line] =~ BLANK_LINE

          offending_range =
            source_range(source.buffer, last_magic_comment.loc.line + 1, 0)

          add_offense(offending_range, location: offending_range)
        end

        def autocorrect(token)
          lambda do |corrector|
            corrector.insert_before(token, "\n")
          end
        end

        private

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
            .select     { |comment| MagicComment.parse(comment.text).any?  }
            .last
        end
      end
    end
  end
end
