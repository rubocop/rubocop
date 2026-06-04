# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks the proper ordering of magic comments and whether
      # a magic comment is not placed before a shebang.
      #
      # @safety
      #   This cop's autocorrection is unsafe because file encoding may change.
      #
      # @example
      #   # bad
      #
      #   # frozen_string_literal: true
      #   # encoding: ascii
      #   p [''.frozen?, ''.encoding] #=> [true, #<Encoding:UTF-8>]
      #
      #   # good
      #
      #   # encoding: ascii
      #   # frozen_string_literal: true
      #   p [''.frozen?, ''.encoding] #=> [true, #<Encoding:US-ASCII>]
      #
      #   # good
      #
      #   #!/usr/bin/env ruby
      #   # encoding: ascii
      #   # frozen_string_literal: true
      #   p [''.frozen?, ''.encoding] #=> [true, #<Encoding:US-ASCII>]
      #
      class OrderedMagicComments < Base
        include FrozenStringLiteral
        extend AutoCorrector

        MSG = 'The encoding magic comment should precede all other magic comments.'

        def on_new_investigation
          return if processed_source.buffer.source.empty?

          encoding_line, other_magic_comment_line = magic_comment_lines

          return unless encoding_line && other_magic_comment_line
          return if encoding_line < other_magic_comment_line

          range = processed_source.buffer.line_range(encoding_line + 1)

          add_offense(range) do |corrector|
            autocorrect(corrector, encoding_line, other_magic_comment_line)
          end
        end

        private

        def autocorrect(corrector, encoding_line, other_magic_comment_line)
          range1 = processed_source.buffer.line_range(encoding_line + 1)
          range2 = processed_source.buffer.line_range(other_magic_comment_line + 1)

          corrector.replace(range1, range2.source)
          corrector.replace(range2, range1.source)
        end

        def magic_comment_lines
          lines = [nil, nil]

          leading_magic_comments.each.with_index do |comment, index|
            if comment.encoding_specified?
              lines[0] = index
            elsif comment.valid?
              lines[1] = index
            end

            return lines if lines[0] && lines[1]
          end

          lines
        end
      end
    end
  end
end
