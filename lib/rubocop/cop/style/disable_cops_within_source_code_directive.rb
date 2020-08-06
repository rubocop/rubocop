# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective

module RuboCop
  module Cop
    module Style
      # Detects comments to enable/disable RuboCop.
      # This is useful if want to make sure that every RuboCop error gets fixed
      # and not quickly disabled with a comment.
      #
      # @example
      #   # bad
      #   # rubocop:disable Metrics/AbcSize
      #   def f
      #   end
      #   # rubocop:enable Metrics/AbcSize
      #
      #   # good
      #   def fixed_method_name_and_no_rubocop_comments
      #   end
      #
      class DisableCopsWithinSourceCodeDirective < Base
        extend AutoCorrector

        # rubocop:enable Lint/RedundantCopDisableDirective
        MSG = 'Comment to disable/enable RuboCop.'

        def on_new_investigation
          processed_source.comments.each do |comment|
            next unless rubocop_directive_comment?(comment)

            add_offense(comment) do |corrector|
              corrector.replace(comment, '')
            end
          end
        end

        private

        def rubocop_directive_comment?(comment)
          CommentConfig::COMMENT_DIRECTIVE_REGEXP.match?(comment.text)
        end
      end
    end
  end
end
