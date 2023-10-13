# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for redundant safe navigation calls.
      # Use cases where a constant, named in camel case for classes and modules is `nil` are rare,
      # and an offense is not detected when the receiver is a snake case constant.
      #
      # For all receivers, the `instance_of?`, `kind_of?`, `is_a?`, `eql?`, `respond_to?`,
      # and `equal?` methods are checked by default.
      # These are customizable with `AllowedMethods` option.
      #
      # The `AllowedMethods` option specifies nil-safe methods,
      # in other words, it is a method that is allowed to skip safe navigation.
      # Note that the `AllowedMethod` option is not an option that specifies methods
      # for which to suppress (allow) this cop's check.
      #
      # In the example below, the safe navigation operator (`&.`) is unnecessary
      # because `NilClass` has methods like `respond_to?` and `is_a?`.
      #
      # @safety
      #   This cop is unsafe, because autocorrection can change the return type of
      #   the expression. An offending expression that previously could return `nil`
      #   will be autocorrected to never return `nil`.
      #
      # @example
      #   # bad
      #   CamelCaseConst&.do_something
      #
      #   # bad
      #   do_something if attrs&.respond_to?(:[])
      #
      #   # good
      #   do_something if attrs.respond_to?(:[])
      #
      #   # bad
      #   while node&.is_a?(BeginNode)
      #     node = node.parent
      #   end
      #
      #   # good
      #   CamelCaseConst.do_something
      #
      #   # good
      #   while node.is_a?(BeginNode)
      #     node = node.parent
      #   end
      #
      #   # good - without `&.` this will always return `true`
      #   foo&.respond_to?(:to_a)
      #
      # @example AllowedMethods: [nil_safe_method]
      #   # bad
      #   do_something if attrs&.nil_safe_method(:[])
      #
      #   # good
      #   do_something if attrs.nil_safe_method(:[])
      #   do_something if attrs&.not_nil_safe_method(:[])
      #
      class RedundantSafeNavigation < Base
        include AllowedMethods
        include RangeHelp
        extend AutoCorrector

        MSG = 'Redundant safe navigation detected.'

        NIL_SPECIFIC_METHODS = (nil.methods - Object.new.methods).to_set.freeze

        SNAKE_CASE = /\A[[:digit:][:upper:]_]+\z/.freeze

        # @!method respond_to_nil_specific_method?(node)
        def_node_matcher :respond_to_nil_specific_method?, <<~PATTERN
          (csend _ :respond_to? (sym %NIL_SPECIFIC_METHODS))
        PATTERN

        # rubocop:disable Metrics/AbcSize
        def on_csend(node)
          unless node.receiver.const_type? && !node.receiver.source.match?(SNAKE_CASE)
            return unless check?(node) && allowed_method?(node.method_name)
            return if respond_to_nil_specific_method?(node)
          end

          range = range_between(node.loc.dot.begin_pos, node.source_range.end_pos)
          add_offense(range) { |corrector| corrector.replace(node.loc.dot, '.') }
        end
        # rubocop:enable Metrics/AbcSize

        private

        def check?(node)
          parent = node.parent
          return false unless parent

          condition?(parent, node) ||
            parent.and_type? ||
            parent.or_type? ||
            (parent.send_type? && parent.negation_method?)
        end

        def condition?(parent, node)
          (parent.conditional? || parent.post_condition_loop?) && parent.condition == node
        end
      end
    end
  end
end
