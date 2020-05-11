# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for unwanted parentheses in parameterless method calls.
      #
      # @example
      #   # bad
      #   object.some_method()
      #
      #   # good
      #   object.some_method
      class MethodCallWithoutArgsParentheses < Cop
        include IgnoredMethods

        MSG = 'Do not use parentheses for method calls with ' \
              'no arguments.'

        def on_send(node)
          return if ineligible_node?(node)
          return unless !node.arguments? && node.parenthesized?
          return if ignored_method?(node.method_name)
          return if same_name_assignment?(node)

          add_offense(node, location: node.loc.begin.join(node.loc.end))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end

        private

        def ineligible_node?(node)
          node.camel_case_method? || node.implicit_call? || node.prefix_not?
        end

        def same_name_assignment?(node)
          any_assignment?(node) do |asgn_node|
            next variable_in_mass_assignment?(node.method_name, asgn_node) if asgn_node.masgn_type?

            asgn_node.loc.name.source == node.method_name.to_s
          end
        end

        def any_assignment?(node)
          node.each_ancestor(*AST::Node::ASSIGNMENTS).any? do |asgn_node|
            # `obj.method = value` parses as (send ... :method= ...), and will
            # not be returned as an `asgn_node` here, however,
            # `obj.method ||= value` parses as (or-asgn (send ...) ...)
            # which IS an `asgn_node`. Similarly, `obj.method += value` parses
            # as (op-asgn (send ...) ...), which is also an `asgn_node`.
            if asgn_node.shorthand_asgn?
              asgn_node, _value = *asgn_node
              next if asgn_node.send_type?
            end

            yield asgn_node
          end
        end

        def variable_in_mass_assignment?(variable_name, node)
          mlhs_node, _mrhs_node = *node
          var_nodes = *mlhs_node

          var_nodes.any? { |n| n.to_a.first == variable_name }
        end
      end
    end
  end
end
