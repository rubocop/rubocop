# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for self-assignments.
      #
      # @example
      #   # bad
      #   foo = foo
      #   foo, bar = foo, bar
      #   Foo = Foo
      #
      #   # good
      #   foo = bar
      #   foo, bar = bar, foo
      #   Foo = Bar
      #
      class SelfAssignment < Base
        MSG = 'Self-assignment detected.'

        ASSIGNMENT_TYPE_TO_RHS_TYPE = {
          lvasgn: :lvar,
          ivasgn: :ivar,
          cvasgn: :cvar,
          gvasgn: :gvar
        }.freeze

        def on_lvasgn(node)
          lhs, rhs = *node
          return unless rhs

          rhs_type = ASSIGNMENT_TYPE_TO_RHS_TYPE[node.type]

          add_offense(node) if rhs.type == rhs_type && rhs.source == lhs.to_s
        end
        alias on_ivasgn on_lvasgn
        alias on_cvasgn on_lvasgn
        alias on_gvasgn on_lvasgn

        def on_casgn(node)
          lhs_scope, lhs_name, rhs = *node
          return unless rhs&.const_type?

          rhs_scope, rhs_name = *rhs
          add_offense(node) if lhs_scope == rhs_scope && lhs_name == rhs_name
        end

        def on_masgn(node)
          add_offense(node) if multiple_self_assignment?(node)
        end

        def on_or_asgn(node)
          lhs, rhs = *node
          add_offense(node) if rhs_matches_lhs?(rhs, lhs)
        end
        alias on_and_asgn on_or_asgn

        private

        def multiple_self_assignment?(node)
          lhs, rhs = *node
          return false unless rhs.array_type?
          return false unless lhs.children.size == rhs.children.size

          lhs.children.zip(rhs.children).all? do |lhs_item, rhs_item|
            rhs_matches_lhs?(rhs_item, lhs_item)
          end
        end

        def rhs_matches_lhs?(rhs, lhs)
          rhs.type == ASSIGNMENT_TYPE_TO_RHS_TYPE[lhs.type] &&
            rhs.children.first == lhs.children.first
        end
      end
    end
  end
end
