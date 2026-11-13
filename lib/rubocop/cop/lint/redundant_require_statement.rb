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
      #   * 2.7+ ... Add `ruby2_keywords` above
      #   * 3.1+ ... Add `fiber` above
      #   * 3.2+ ... Add `set` above
      #   * 4.0+ ... Add `pathname` above
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
          return unless redundant_require_statement?(node) && statement?(node)
          return unless modifier_form_body?(node) || own_lines?(node)

          add_offense(node) do |corrector|
            if modifier_form_body?(node)
              corrector.insert_after(node.parent, "\nend")

              range = range_with_surrounding_space(node.source_range, side: :right)
            else
              range = range_by_whole_lines(node.source_range, include_final_newline: true)
            end

            corrector.remove(range)
          end
        end

        private

        def statement?(node)
          parent = node.parent
          return true unless parent
          return !parent.endless? if parent.any_def_type?
          return !parent.ternary? && !parent.condition.equal?(node) if parent.if_type?
          return !parent.condition.equal?(node) if parent.type?(:while, :until)

          parent.type?(:begin, :kwbegin, :any_block, :class, :module, :sclass, :case,
                       :when, :in_pattern, :rescue, :resbody, :ensure)
        end

        def modifier_form_body?(node)
          node.parent.respond_to?(:modifier_form?) && node.parent.modifier_form?
        end

        def own_lines?(node)
          range = node.source_range
          lines = range_by_whole_lines(range)

          lines.with(end_pos: range.begin_pos).source.strip.empty? &&
            lines.with(begin_pos: range.end_pos).source.match?(/\A\s*(#.*)?\z/)
        end

        # rubocop:disable-next Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def redundant_feature?(feature_name)
          feature_name == 'enumerator' ||
            (target_ruby_version >= 2.1 && feature_name == 'thread') ||
            (target_ruby_version >= 2.2 && RUBY_22_LOADED_FEATURES.include?(feature_name)) ||
            (target_ruby_version >= 2.7 && feature_name == 'ruby2_keywords') ||
            (target_ruby_version >= 3.1 && feature_name == 'fiber') ||
            (target_ruby_version >= 3.2 && feature_name == 'set') ||
            (target_ruby_version >= 4.0 && feature_name == 'pathname')
        end
      end
    end
  end
end
