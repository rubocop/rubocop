# encoding: utf-8

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

        MSG = 'Missing frozen string literal comment.'.freeze
        FROZEN_STRING_LITERAL = '# frozen_string_literal:'.freeze
        FROZEN_STRING_LITERAL_ENABLED = '# frozen_string_literal: true'.freeze
        SHEBANG = '#!'.freeze

        def_node_matcher :frozen_strings, '{(send {dstr str} :<< ...)
                                            (send {dstr str} :freeze)}'

        def investigate(processed_source)
          return unless style == :always
          return if processed_source.buffer.source.empty?

          return if frozen_string_literal_comment_exists?(processed_source)

          offense(processed_source)
        end

        def on_send(node)
          return if target_ruby_version < 2.3 && RUBY_VERSION < '2.3.0'
          return unless style == :when_needed
          return if frozen_string_literal_comment_exists?(processed_source)

          frozen_strings(node) { offense(processed_source) }
        end

        def autocorrect(_node)
          lambda do |corrector|
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

        private

        def frozen_string_literal_comment_exists?(processed_source)
          first_three_lines =
            [processed_source[0], processed_source[1], processed_source[2]]
          first_three_lines.compact!
          first_three_lines.any? do |line|
            line.start_with?(FROZEN_STRING_LITERAL)
          end
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

        def offense(processed_source)
          last_special_comment = last_special_comment(processed_source)
          last_special_comment ||= processed_source.tokens[0]
          range = source_range(processed_source.buffer, 0, 0)

          add_offense(last_special_comment, range, MSG)
        end
      end
    end
  end
end
