# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces the object-oriented paradigm by banning conditional
      # statement.
      #
      # By default, this cop is strict. Some configuration options allow for
      # less restriction.
      #
      # @example
      #   # bad
      #   case statement
      #   when condition
      #     something
      #   else
      #     # do something
      #   end
      #
      #   if condition
      #     something
      #   end
      #
      # @example AllowGuardClause: true
      #   # allow
      #   def stuff
      #     return if condition
      #     something
      #   end
      #
      # @example AllowModifierForm: true
      #   # allow
      #   variable = something if condition
      #
      # @example AllowTernaryOperator: true
      #   # allow
      #   condition ? stuff : something
      #
      class ProceduralConditionStatement < Cop
        MSG = 'Avoid condition statement.'

        def on_case(node)
          add_offense(node, location: :keyword)
        end

        def on_if(node)
          return if allow_guard_clause? && guard_clause?(node) ||
                    modifier_form?(node) || ternary?(node)

          add_offense(node, location: location(node))
        end

        private

        def guard_clause?(node)
          node.if_branch&.guard_clause? ||
            node.else_branch&.guard_clause?
        end

        def modifier_form?(node)
          allow_modifier_form? && node.modifier_form? &&
            !guard_clause?(node)
        end

        def ternary?(node)
          allow_ternary_operator? && node.ternary?
        end

        def allow_guard_clause?
          cop_config.fetch('AllowGuardClause', false)
        end

        def allow_modifier_form?
          cop_config.fetch('AllowModifierForm', false)
        end

        def allow_ternary_operator?
          cop_config.fetch('AllowTernaryOperator', false)
        end

        def location(node)
          node.ternary? ? :expression : :keyword
        end
      end
    end
  end
end
