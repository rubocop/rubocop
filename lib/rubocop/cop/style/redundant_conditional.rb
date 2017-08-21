# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant returning of true/false in conditionals.
      #
      # @example
      #   # bad
      #   x == y ? true : false
      #
      #   # bad
      #   if x == y
      #     true
      #   else
      #     false
      #   end
      #
      #   # good
      #   x == y
      #
      #   # bad
      #   x == y ? false : true
      #
      #   # good
      #   x != y
      class RedundantConditional < Cop
        COMPARISON_OPERATORS = RuboCop::AST::Node::COMPARISON_OPERATORS

        MSG = 'This conditional expression can just be replaced by %s'.freeze

        def on_if(node)
          return unless offense?(node)

          add_offense(node,
                      :expression,
                      format(MSG, replacement_condition(node)))
        end

        private

        def_node_matcher :redundant_condition?, <<-RUBY
          (if (send _ {:#{COMPARISON_OPERATORS.join(' :')}} _) true false)
        RUBY

        def_node_matcher :redundant_condition_inverted?, <<-RUBY
          (if (send _ {:#{COMPARISON_OPERATORS.join(' :')}} _) false true)
        RUBY

        def offense?(node)
          return if node.modifier_form?
          redundant_condition?(node) || redundant_condition_inverted?(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.expression, replacement_condition(node))
          end
        end

        def replacement_condition(node)
          invert_expression = (
            (node.if? || node.ternary?) &&
            redundant_condition_inverted?(node)
          ) || (node.unless? && redundant_condition?(node))

          condition = node.condition.source

          invert_expression ? "!(#{condition})" : condition
        end
      end
    end
  end
end
