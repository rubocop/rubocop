# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop is designed to help upgrade to Ruby 3.0. It will add the
      # comment `# frozen_string_literal: true` to the top of files to
      # enable frozen string literals. Frozen string literals may be default
      # in Ruby 3.0. The comment will be added below a shebang and encoding
      # comment. The frozen string literal comment is only valid in Ruby 2.3+.
      #
      # @example EnforcedStyle: when_needed (default)
      #   # The `when_needed` style will add the frozen string literal comment
      #   # to files only when the `TargetRubyVersion` is set to 2.3+.
      #   # bad
      #   module Foo
      #     # ...
      #   end
      #
      #   # good
      #   # frozen_string_literal: true
      #
      #   module Foo
      #     # ...
      #   end
      #
      # @example EnforcedStyle: always
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

        MSG = 'Missing magic comment `# frozen_string_literal: true`.'.freeze
        MSG_UNNECESSARY = 'Unnecessary frozen string literal comment.'.freeze
        SHEBANG = '#!'.freeze

        def investigate(processed_source)
          return if style == :when_needed && target_ruby_version < 2.3
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

          if processed_source.tokens[token_number].text =~
             Encoding::ENCODING_PATTERN
            token = processed_source.tokens[token_number]
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
          last_special_comment = last_special_comment(processed_source)
          if last_special_comment.nil?
            corrector.insert_before(correction_range, preceding_comment)
          else
            corrector.insert_after(correction_range, proceeding_comment)
          end
        end

        def preceding_comment
          if processed_source.tokens[0].space_before?
            "#{FROZEN_STRING_LITERAL_ENABLED}\n"
          else
            "#{FROZEN_STRING_LITERAL_ENABLED}\n\n"
          end
        end

        def proceeding_comment
          last_special_comment = last_special_comment(processed_source)
          if processed_source.following_line(last_special_comment).empty?
            "\n#{FROZEN_STRING_LITERAL_ENABLED}"
          else
            "\n#{FROZEN_STRING_LITERAL_ENABLED}\n"
          end
        end

        def correction_range
          last_special_comment = last_special_comment(processed_source)

          if last_special_comment.nil?
            range_with_surrounding_space(range: processed_source.tokens[0],
                                         side: :left)
          else
            last_special_comment.pos
          end
        end
      end
    end
  end
end
