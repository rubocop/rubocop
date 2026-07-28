# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective

module RuboCop
  module Cop
    module Style
      # Detects comments to enable/disable RuboCop.
      # This is useful if you want to make sure that every RuboCop error gets fixed
      # and not quickly disabled with a comment.
      #
      # Specific cops can be allowed with the `AllowedCops` configuration. Note that
      # if this configuration is set, `rubocop:disable all` is still disallowed.
      #
      # Directives with trailing comments can be allowed with the
      # `AllowTrailingComment` configuration. The trailing comment must start with
      # `--` and include explanatory text.
      #
      # @example
      #   # bad
      #   # rubocop:disable Metrics/AbcSize
      #   def foo
      #   end
      #   # rubocop:enable Metrics/AbcSize
      #
      #   # good
      #   def foo
      #   end
      #
      # @example AllowedCops: [Metrics/AbcSize]
      #   # good
      #   # rubocop:disable Metrics/AbcSize
      #   def foo
      #   end
      #   # rubocop:enable Metrics/AbcSize
      #
      # @example AllowTrailingComment: true
      #   # good
      #   # rubocop:disable Metrics/AbcSize -- Reason for disabling.
      #   def foo
      #   end
      #   # rubocop:enable Metrics/AbcSize
      #
      class DisableCopsWithinSourceCodeDirective < Base
        extend AutoCorrector

        # rubocop:enable Lint/RedundantCopDisableDirective
        MSG = 'RuboCop disable/enable directives are not permitted.'
        MSG_FOR_COPS = 'RuboCop disable/enable directives for %<cops>s are not permitted.'

        def on_new_investigation
          documented_cops = []

          processed_source.comments.each do |comment|
            directive_comment = DirectiveComment.new(comment)
            directive_cops = directive_cops(directive_comment)
            disallowed_cops = directive_cops - allowed_cops

            next unless disallowed_cops.any?

            if trailing_comment_allowed?(directive_comment, directive_cops, documented_cops)
              documented_cops |= directive_cops if directive_comment.disabled?
              next
            end

            register_offense(comment, directive_cops, disallowed_cops)
          end
        end

        private

        def register_offense(comment, directive_cops, disallowed_cops)
          message = if any_cops_allowed?
                      format(MSG_FOR_COPS, cops: "`#{disallowed_cops.join('`, `')}`")
                    else
                      MSG
                    end

          add_offense(comment, message: message) do |corrector|
            replacement = ''

            if directive_cops.length != disallowed_cops.length
              replacement = comment.text.sub(/#{Regexp.union(disallowed_cops)},?\s*/, '')
                                   .sub(/,\s*$/, '')
            end

            corrector.replace(comment, replacement)
          end
        end

        def directive_cops(directive_comment)
          match_captures = directive_comment.match_captures
          match_captures && match_captures[1] ? match_captures[1].split(',').map(&:strip) : []
        end

        def allowed_cops
          Array(cop_config['AllowedCops'])
        end

        def trailing_comment_allowed?(directive_comment, directive_cops, documented_cops)
          return false unless cop_config['AllowTrailingComment']

          if directive_comment.disabled?
            trailing_comment?(directive_comment)
          elsif directive_comment.enabled?
            (directive_cops - documented_cops).empty?
          else
            false
          end
        end

        def trailing_comment?(directive_comment)
          trailing_comment_text(directive_comment).match?(/\A\s*#{DirectiveComment::TRAILING_COMMENT_MARKER}\s+\S/)
        end

        def trailing_comment_text(directive_comment)
          comment = directive_comment.comment
          directive_end = directive_comment.range.end_pos - comment.source_range.begin_pos

          comment.text[directive_end..].to_s
        end

        def any_cops_allowed?
          allowed_cops.any?
        end
      end
    end
  end
end
