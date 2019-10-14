# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop is designed to help you transition from mutable string literals
      # to frozen string literals.
      # It will add the comment `# frozen_string_literal: true` to the top of
      # files to enable frozen string literals. Frozen string literals may be
      # default in future Ruby. The comment will be added below a shebang and
      # encoding comment. The frozen string literal comment is only valid in
      # Ruby 2.3+.
      #
      # Note that the cop will ignore files where the comment exists but is set
      # to `false` instead of `true`.
      #
      # @example EnforcedStyle: always (default)
      #   # The `always` style will always add the frozen string literal comment
      #   # to a file, regardless of the Ruby version or if `freeze` or `<<` are
      #   # called on a string literal.
      #   # bad
      #   module Bar
      #     # ...
      #   end
      #
      #   # good
      #   # frozen_string_literal: true
      #
      #   module Bar
      #     # ...
      #   end
      #
      #   # good
      #   # frozen_string_literal: false
      #
      #   module Bar
      #     # ...
      #   end
      #
      # @example EnforcedStyle: never
      #   # The `never` will enforce that the frozen string literal comment does
      #   # not exist in a file.
      #   # bad
      #   # frozen_string_literal: true
      #
      #   module Baz
      #     # ...
      #   end
      #
      #   # good
      #   module Baz
      #     # ...
      #   end
      class FrozenStringLiteralComment < Cop
        include ConfigurableEnforcedStyle
        include FrozenStringLiteral
        include RangeHelp

        MSG = 'Missing magic comment `# frozen_string_literal: true`.'
        MSG_UNNECESSARY = 'Unnecessary frozen string literal comment.'
        SHEBANG = '#!'

        def investigate(processed_source)
          return if processed_source.tokens.empty?

          if frozen_string_literal_comment_exists?
            check_for_no_comment(processed_source)
          else
            check_for_comment(processed_source)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if style == :never
              remove_comment(corrector, node)
            else
              insert_comment(corrector)
            end
          end
        end

        private

        def check_for_no_comment(processed_source)
          unnecessary_comment_offense(processed_source) if style == :never
        end

        def check_for_comment(processed_source)
          offense(processed_source) unless style == :never
        end

        def last_special_comment(processed_source)
          token_number = 0
          if processed_source.tokens[token_number].text.start_with?(SHEBANG)
            token = processed_source.tokens[token_number]
            token_number += 1
          end

          next_token = processed_source.tokens[token_number]
          if next_token && next_token.text =~ Encoding::ENCODING_PATTERN
            token = next_token
          end

          token
        end

        def frozen_string_literal_comment(processed_source)
          processed_source.find_token do |token|
            token.text.start_with?(FrozenStringLiteral::FROZEN_STRING_LITERAL)
          end
        end

        def offense(processed_source)
          last_special_comment = last_special_comment(processed_source)
          range = source_range(processed_source.buffer, 0, 0)

          add_offense(last_special_comment, location: range)
        end

        def unnecessary_comment_offense(processed_source)
          frozen_string_literal_comment =
            frozen_string_literal_comment(processed_source)

          add_offense(frozen_string_literal_comment,
                      location: frozen_string_literal_comment.pos,
                      message: MSG_UNNECESSARY)
        end

        def remove_comment(corrector, node)
          corrector.remove(range_with_surrounding_space(range: node.pos,
                                                        side: :right))
        end

        def insert_comment(corrector)
          comment = last_special_comment(processed_source)

          if comment
            corrector.insert_after(line_range(comment.line), following_comment)
          else
            corrector.insert_before(line_range(1), preceding_comment)
          end
        end

        def line_range(line)
          processed_source.buffer.line_range(line)
        end

        def preceding_comment
          "#{FROZEN_STRING_LITERAL_ENABLED}\n"
        end

        def following_comment
          "\n#{FROZEN_STRING_LITERAL_ENABLED}"
        end
      end
    end
  end
end
