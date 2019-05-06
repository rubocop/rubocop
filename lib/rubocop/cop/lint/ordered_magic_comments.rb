# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      #
      # Checks the proper ordering of magic comments and whether
      # a magic comment is not placed before a shebang.
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
      class OrderedMagicComments < Cop
        include FrozenStringLiteral

        MSG = 'The encoding magic comment should precede all other ' \
              'magic comments.'

        def investigate(processed_source)
          return if processed_source.buffer.source.empty?

          encoding_line, frozen_string_literal_line = magic_comment_lines

          return unless encoding_line && frozen_string_literal_line
          return if encoding_line < frozen_string_literal_line

          range = processed_source.buffer.line_range(encoding_line + 1)

          add_offense(range, location: range)
        end

        def autocorrect(_node)
          encoding_line, frozen_string_literal_line = magic_comment_lines

          range1 = processed_source.buffer.line_range(encoding_line + 1)
          range2 =
            processed_source.buffer.line_range(frozen_string_literal_line + 1)

          lambda do |corrector|
            corrector.replace(range1, range2.source)
            corrector.replace(range2, range1.source)
          end
        end

        private

        def magic_comment_lines
          lines = [nil, nil]

          magic_comments.each.with_index do |comment, index|
            if comment.encoding_specified?
              lines[0] = index
            elsif comment.frozen_string_literal_specified?
              lines[1] = index
            end

            return lines if lines[0] && lines[1]
          end

          lines
        end

        def magic_comments
          leading_comment_lines.map { |line| MagicComment.parse(line) }
        end
      end
    end
  end
end
