# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer logical expressions over predicates on `Array` literals.
      #
      # Logical expressions are more performant because they don't allocate an array and
      # because they short-circuit, whereas array literal predicates always evaluate
      # every element.
      #
      # @safety
      #   Autocorrection is unsafe because `any?`/`all?` return a boolean while
      #   logical expressions return an expression's value.
      #
      #   It's also unsafe because logical expressions short-circuit; if any element
      #   is a method call with side effects, they may not run anymore within a
      #   logical expression.
      #
      #   [source,ruby]
      #   ----
      #   [foo, method_with_side_effects].any?
      #   # always evaluates `method_with_side_effects`
      #
      #   foo || method_with_side_effects
      #   # evaluates `method_with_side_effects` only if `foo` is falsey
      #   ----
      #
      # @example
      #
      #   # bad
      #   [foo, bar, baz].any?
      #   [foo, bar, baz].all?
      #
      #   # good
      #   (foo || bar || baz)
      #   (foo && bar && baz)
      #
      #   # good - arrays with splat arguments are ignored
      #   [foo, *bar].any?
      #   [foo, *bar].all?
      #
      # @example MaxCheckedSize: 3 (default)
      #
      #   # good
      #   [foo, bar, baz, quux].any?
      #   [foo, bar, baz, quux].all?
      #
      # @example MaxCheckedSize: 4
      #
      #   # bad
      #   [foo, bar, baz, quux].any?
      #   [foo, bar, baz, quux].all?
      #
      #    # good
      #   (foo || bar || baz || quux)
      #   (foo && bar && baz && quux)
      #
      class ArrayLiteralAsLogicalExpression < Base
        extend AutoCorrector

        MSG_OR = 'Prefer an OR expression instead.'
        MSG_AND = 'Prefer an AND expression instead.'

        RESTRICT_ON_SEND = %i[any? all?].freeze

        # @!method array_literal_as_logical_expression(node)
        def_node_matcher :array_literal_as_logical_expression, <<~PATTERN
          (send (array !splat_type?+) ${:any? :all?})
        PATTERN

        def on_send(node)
          return unless (method_name = array_literal_as_logical_expression(node))
          return if node.block_literal?
          return if node.receiver.child_nodes.size > max_checked_size

          or_expression = method_name == :any?
          add_offense(node, message: or_expression ? MSG_OR : MSG_AND) do |corrector|
            corrector.replace(node, replacement(node, or_expression))
          end
        end

        private

        def replacement(node, or_expression)
          array_item_sources = node.receiver.child_nodes.map(&:source)
          operator = or_expression ? ' || ' : ' && '

          "(#{array_item_sources.join(operator)})"
        end

        def max_checked_size
          cop_config['MaxCheckedSize']
        end
      end
    end
  end
end
