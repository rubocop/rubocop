# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for redundant safe navigation calls.
      # `instance_of?`, `kind_of?`, `is_a?`, `eql?`, `respond_to?`, and `equal?` methods
      # are checked by default. These are customizable with `AllowedMethods` option.
      #
      # This cop is marked as unsafe, because auto-correction can change the
      # return type of the expression. An offending expression that previously
      # could return `nil` will be auto-corrected to never return `nil`.
      #
      # In the example below, the safe navigation operator (`&.`) is unnecessary
      # because `NilClass` has methods like `respond_to?` and `is_a?`.
      #
      # @example
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
      #   while node.is_a?(BeginNode)
      #     node = node.parent
      #   end
      #
      #   # good - without `&.` this will always return `true`
      #   foo&.respond_to?(:to_a)
      #
      class RedundantSafeNavigation < Base
        include AllowedMethods
        include RangeHelp
        extend AutoCorrector

        MSG = 'Redundant safe navigation detected.'

        NIL_SPECIFIC_METHODS = (nil.methods - Object.new.methods).to_set.freeze

        def_node_matcher :respond_to_nil_specific_method?, <<~PATTERN
          (csend _ :respond_to? (sym %NIL_SPECIFIC_METHODS))
        PATTERN

        def on_csend(node)
          return unless check?(node) && allowed_method?(node.method_name)
          return if respond_to_nil_specific_method?(node)

          range = range_between(node.loc.dot.begin_pos, node.source_range.end_pos)
          add_offense(range) do |corrector|
            corrector.replace(node.loc.dot, '.')
          end
        end

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
