# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for unnecessary `require` statement.
      #
      # The following features are unnecessary `require` statement because
      # they are already loaded. e.g. Ruby 2.2:
      #
      #   ruby -ve 'p $LOADED_FEATURES.reject { |feature| %r|/| =~ feature }'
      #   ruby 2.2.8p477 (2017-09-14 revision 59906) [x86_64-darwin13]
      #   ["enumerator.so", "rational.so", "complex.so", "thread.rb"]
      #
      # Below are the features that each `TargetRubyVersion` targets.
      #
      #   * 2.0+ ... `enumerator`
      #   * 2.1+ ... `thread`
      #   * 2.2+ ... Add `rational` and `complex` above
      #   * 2.5+ ... Add `pp` above
      #   * 2.7+ ... Add `ruby2_keywords` above
      #   * 3.1+ ... Add `fiber` above
      #
      # This cop target those features.
      #
      # @example
      #   # bad
      #   require 'unloaded_feature'
      #   require 'thread'
      #
      #   # good
      #   require 'unloaded_feature'
      class RedundantRequireStatement < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove unnecessary `require` statement.'
        RESTRICT_ON_SEND = %i[require].freeze
        RUBY_22_LOADED_FEATURES = %w[rational complex].freeze

        # @!method redundant_require_statement?(node)
        def_node_matcher :redundant_require_statement?, <<~PATTERN
          (send nil? :require
            (str #redundant_feature?))
        PATTERN

        def on_send(node)
          return unless redundant_require_statement?(node)

          add_offense(node) do |corrector|
            range = range_with_surrounding_space(node.loc.expression, side: :right)

            corrector.remove(range)
          end
        end

        private

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def redundant_feature?(feature_name)
          feature_name == 'enumerator' ||
            (target_ruby_version >= 2.1 && feature_name == 'thread') ||
            (target_ruby_version >= 2.2 && RUBY_22_LOADED_FEATURES.include?(feature_name)) ||
            (target_ruby_version >= 2.5 && feature_name == 'pp') ||
            (target_ruby_version >= 2.7 && feature_name == 'ruby2_keywords') ||
            (target_ruby_version >= 3.1 && feature_name == 'fiber')
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      end
    end
  end
end
