# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Check to make sure that if safe navigation is used for a method
      # call in an `&&` or `||` condition that safe navigation is used for all
      # method calls on that same object.
      #
      # Options:
      # `ShortCircuit` (default `false`) - Enforces short circuit syntax for `&&` conditions. Only
      # the first method call is required to use safe navigation. All other method calls do not
      # use safe navigation. There is no impact on `||` conditions.
      #
      # @example
      #   # bad
      #   foo&.bar && foo.baz
      #
      #   # bad
      #   foo.bar || foo&.baz
      #
      #   # bad
      #   foo&.bar && (foobar.baz || foo.baz)
      #
      #   # good
      #   foo.bar && foo.baz
      #
      #   # good
      #   foo&.bar || foo&.baz
      #
      #   # good
      #   foo&.bar && (foobar.baz || foo&.baz)
      #
      # @example ShortCircuit: true
      #   # bad
      #   foo.bar && foo&.baz
      #
      #   # bad
      #   foo.bar || foo&.baz
      #
      #   # bad
      #   foo&.bar && foo&.baz
      #
      #   # bad
      #   foo.bar || foo.bar && foo.qux
      #
      #   # good
      #   foo&.bar && foo.baz
      #
      #   # good
      #   foo&.bar || foo&.baz
      #
      #   # good
      #   foo&.bar && foo.baz
      #
      #   # good
      #   foo&.bar || foo&.bar && foo.qux
      #
      class SafeNavigationConsistency < Base
        include IgnoredNode
        include NilMethods
        extend AutoCorrector

        MSG = 'Ensure that safe navigation is used consistently inside of `&&` and `||`.'
        SHORT_CIRCUIT_MSG = 'Only use safe navigation for the first operand of `&&`.'
        VARIABLE_ASSIGNMENT_TYPES = %i[casgn cvasgn gvasgn ivasgn lvasgn].freeze
        DOT_METHODS = %i[send csend].freeze

        def on_csend(node)
          return unless node.parent&.operator_keyword? # This filters out block calls

          if cop_config['ShortCircuit']
            check_with_short_circuit(node)
          else
            check_for_unsafe_methods(node)
          end
        end

        def check_with_short_circuit(node)
          method_calls = extract_conditions(node, DOT_METHODS)

          first_method, *other_methods_with_same_receiver =
            methods_with_same_receiver(method_calls, node.receiver)

          return if all_methods_compliant_with_short_circuit(first_method,
                                                             other_methods_with_same_receiver)

          other_methods_with_same_receiver.each do |method|
            add_short_circuit_offense(first_method, method)
          end
        end

        def check_for_unsafe_methods(node)
          method_calls = extract_conditions(node, [:send])
          safe_nav_receiver = node.receiver
          unsafe_method_calls = methods_with_same_receiver(method_calls, safe_nav_receiver)

          unsafe_method_calls.each do |unsafe_method_call|
            location = location(node, unsafe_method_call)

            add_offense(location) do |corrector|
              add_safe_navigation(corrector, unsafe_method_call)
            end

            ignore_node(unsafe_method_call)
          end
        end

        private

        def extract_conditions(node, method_types)
          ancestor = top_conditional_ancestor(node)
          conditions = ancestor.conditions
          conditions.select { |condition| method_types.include?(condition.type) }
        end

        def all_methods_compliant_with_short_circuit(first_method, other_methods)
          # e.g. `foo&.bar && foo.baz && foo.qux`
          first_method.csend_type? &&
            other_methods.all?(&:send_type?) &&
            other_methods.map(&:parent).all?(&:and_type?)
        end

        def add_short_circuit_offense(first_method, node)
          location = first_method.loc.expression.join(node.loc.expression)
          conditional_parent = next_conditional_ancestor(node)

          operator = if conditional_parent.rhs == node
                       conditional_parent
                     else
                       next_conditional_ancestor(conditional_parent)
                     end

          if operator.and_type?
            add_offense(location, message: SHORT_CIRCUIT_MSG)
          elsif operator.or_type?
            add_offense(location)
          end
        end

        def add_safe_navigation(corrector, node)
          return unless node.dot?

          corrector.insert_before(node.loc.dot, '&')
        end

        def remove_safe_navigation(corrector, node)
          return unless node.safe_navigation?

          corrector.replace(node.loc.dot, '.')
        end

        def location(node, unsafe_method_call)
          node.source_range.join(unsafe_method_call.source_range)
        end

        def next_conditional_ancestor(node)
          parent = node&.parent
          return parent if parent&.operator_keyword?

          grandparent = parent.parent
          return unless parent&.begin_type?

          return grandparent if grandparent.operator_keyword?
        end

        def top_conditional_ancestor(node)
          parent = node.parent
          unless parent &&
                 (parent.operator_keyword? ||
                  (parent.begin_type? && parent.parent && parent.parent.operator_keyword?))
            return node
          end

          top_conditional_ancestor(parent)
        end

        def methods_with_same_receiver(method_calls, safe_nav_receiver)
          method_calls.select do |method_call|
            safe_nav_receiver == method_call.receiver &&
              !nil_methods.include?(method_call.method_name) &&
              !ignored_node?(method_call)
          end
        end

        def dot_style_method_call?(node)
          node.dot? || node.safe_navigation?
        end
      end
    end
  end
end
