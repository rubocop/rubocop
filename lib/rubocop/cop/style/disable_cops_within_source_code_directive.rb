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
      # Alternatively, specific cops can be disallowed with the `DisallowedCops`
      # configuration. When `DisallowedCops` is set, only directives for the listed
      # cops (and `all`) will be flagged. This is useful when you want
      # to protect a small set of critical cops from being disabled rather than
      # allowlisting all other cops. `AllowedCops` and `DisallowedCops` should not
      # both be set at the same time; if `DisallowedCops` is set, it takes precedence.
      #
      # With `AllowTrailingComment` set to `true`, a disable directive carrying
      # a `--` trailing justification comment is allowed, so a team can require
      # every disable to be documented instead of banning them outright. Enable
      # directives are not checked in this mode, since they end a suppression
      # rather than start one.
      #
      # This cop cannot be disabled via directive comments when it is explicitly
      # enabled with `Enabled: true`. This prevents users from bypassing the cop
      # with `# rubocop:disable Style/DisableCopsWithinSourceCodeDirective`.
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
      # @example DisallowedCops: [Lint/Void]
      #   # bad
      #   # rubocop:disable Lint/Void
      #   foo
      #   # rubocop:enable Lint/Void
      #
      #   # good
      #   # rubocop:disable Metrics/AbcSize
      #   foo
      #   # rubocop:enable Metrics/AbcSize
      #
      # @example AllowTrailingComment: true
      #   # bad
      #   x = 0 # rubocop:disable Layout/SpaceAroundOperators
      #
      #   # good
      #   x = 0 # rubocop:disable Layout/SpaceAroundOperators -- would misalign the table
      #
      class DisableCopsWithinSourceCodeDirective < Base
        extend AutoCorrector

        # rubocop:enable Lint/RedundantCopDisableDirective
        MSG = 'RuboCop disable/enable directives are not permitted.'
        MSG_FOR_COPS = 'RuboCop disable/enable directives for %<cops>s are not permitted.'
        MSG_MISSING_REASON = 'RuboCop disable directives without a `--` justification ' \
                             'comment are not permitted.'

        def on_new_investigation
          processed_source.comments.each do |comment|
            directive = DirectiveComment.new(comment)
            next if allow_trailing_comment? && (directive.reason || directive.enabled?)

            directive_cops = directive_cops(directive)
            disallowed_cops = compute_disallowed_cops(directive_cops)

            next unless disallowed_cops.any?

            register_offense(comment, directive_cops, disallowed_cops)
          end
        end

        private

        def compute_disallowed_cops(directive_cops)
          if disallowed_cops_config.any?
            if directive_cops.include?('all')
              directive_cops
            else
              directive_cops.uniq.select { |cop| disallowed_cops_config.include?(cop) }
            end
          else
            directive_cops.reject { |cop| allowed_cops.include?(cop) }
          end
        end

        def register_offense(comment, directive_cops, disallowed_cops)
          add_offense(comment, message: offense_message(disallowed_cops)) do |corrector|
            replacement = ''

            if directive_cops.length != disallowed_cops.length
              replacement = comment.text.sub(/#{Regexp.union(disallowed_cops)},?\s*/, '')
                                   .sub(/,\s*$/, '')
            end

            corrector.replace(comment, replacement)
          end
        end

        def offense_message(disallowed_cops)
          if allow_trailing_comment?
            MSG_MISSING_REASON
          elsif any_cops_allowed? || disallowed_cops_config.any?
            format(MSG_FOR_COPS, cops: "`#{disallowed_cops.join('`, `')}`")
          else
            MSG
          end
        end

        def directive_cops(directive)
          match_captures = directive.match_captures
          match_captures && match_captures[1] ? match_captures[1].split(',').map(&:strip) : []
        end

        def allow_trailing_comment?
          cop_config['AllowTrailingComment']
        end

        def allowed_cops
          @allowed_cops ||= Array(cop_config['AllowedCops']).to_set
        end

        def any_cops_allowed?
          allowed_cops.any?
        end

        def disallowed_cops_config
          @disallowed_cops_config ||= Array(cop_config['DisallowedCops']).to_set
        end
      end
    end
  end
end
