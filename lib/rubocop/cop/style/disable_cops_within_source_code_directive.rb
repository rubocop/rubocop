# frozen_string_literal: true

# rubocop:disable Lint/RedundantCopDisableDirective

module RuboCop
  module Cop
    module Style
      # Detects comments to enable/disable RuboCop.
      # This is useful if want to make sure that every RuboCop error gets fixed
      # and not quickly disabled with a comment.
      #
      # Specific cops can be allowed with the `AllowedCops` configuration. Note that
      # if this configuration is set, `rubocop:disable all` is still disallowed.
      #
      # Alternatively, specific cops can be disallowed with the `DisallowedCops`
      # configuration. This is useful when you want to prevent only a few cops
      # from being disabled, while allowing all others.
      #
      # NOTE: The `AllowedCops` and `DisallowedCops` configurations are mutually
      # exclusive and should not be used together.
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
      # @example DisallowedCops: [Lint/Debugger]
      #   # bad
      #   # rubocop:disable Lint/Debugger
      #   debugger
      #   # rubocop:enable Lint/Debugger
      #
      #   # good
      #   # rubocop:disable Metrics/AbcSize
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
          processed_source.comments.each do |comment|
            directive_cops = directive_cops(comment)
            disallowed_cops = compute_disallowed_cops(directive_cops)

            next unless disallowed_cops.any?

            register_offense(comment, directive_cops, disallowed_cops)
          end
        end

        private

        def register_offense(comment, directive_cops, disallowed_cops)
          message = if cop_specific_mode?
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

        def compute_disallowed_cops(directive_cops)
          if disallowed_cops_config.any?
            directive_cops & disallowed_cops_config
          else
            directive_cops - allowed_cops
          end
        end

        def directive_cops(comment)
          match_captures = DirectiveComment.new(comment).match_captures
          match_captures && match_captures[1] ? match_captures[1].split(',').map(&:strip) : []
        end

        def allowed_cops
          Array(cop_config['AllowedCops'])
        end

        def disallowed_cops_config
          Array(cop_config['DisallowedCops'])
        end

        def cop_specific_mode?
          allowed_cops.any? || disallowed_cops_config.any?
        end
      end
    end
  end
end
