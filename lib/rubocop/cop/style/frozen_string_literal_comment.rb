# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop is designed to help upgrade to Ruby 3.0. It will add the
      # comment `# frozen_string_literal: true` to the top of files to
      # enable frozen string literals. Frozen string literals will be default
      # in Ruby 3.0. The comment will be added below a shebang and encoding
      # comment. The frozen string literal comment is only valid in Ruby 2.3+.
      class FrozenStringLiteralComment < Cop
        include ConfigurableEnforcedStyle
        include FrozenStringLiteral

        MSG = 'Missing frozen string literal comment.'.freeze
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
              corrector.remove(range_with_surrounding_space(node.pos, :right))
            else
              last_special_comment = last_special_comment(processed_source)
              if last_special_comment.nil?
                corrector.insert_before(processed_source.tokens[0].pos,
                                        "#{FROZEN_STRING_LITERAL_ENABLED}\n")
              else
                corrector.insert_after(last_special_comment.pos,
                                       "\n#{FROZEN_STRING_LITERAL_ENABLED}")
              end
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
          processed_source.tokens.find do |token|
            token.text.start_with?(FrozenStringLiteral::FROZEN_STRING_LITERAL)
          end
        end

        def offense(processed_source)
          last_special_comment = last_special_comment(processed_source)
          range = source_range(processed_source.buffer, 0, 0)

          add_offense(last_special_comment, range, MSG)
        end

        def unnecessary_comment_offense(processed_source)
          frozen_string_literal_comment =
            frozen_string_literal_comment(processed_source)

          add_offense(frozen_string_literal_comment,
                      frozen_string_literal_comment.pos,
                      MSG_UNNECESSARY)
        end
      end
    end
  end
end
