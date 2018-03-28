# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop check to make sure that if safe navigation is used for a method
      # call in an `&&` or `||` condition that safe navigation is used for all
      # method calls on that same object.
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
      class SafeNavigationConsistency < Cop
        MSG = 'Ensure that safe navigation is used consistently ' \
          'inside of `&&` and `||`.'.freeze

        def on_csend(node)
          return unless node.parent &&
                        AST::Node::OPERATOR_KEYWORDS.include?(node.parent.type)
          check(node)
        end

        def check(node)
          ancestor = top_conditional_ancestor(node)
          conditions = ancestor.conditions
          safe_nav_receiver = node.receiver

          method_calls = conditions.select(&:send_type?)
          unsafe_method_calls = method_calls.select do |method_call|
            safe_nav_receiver == method_call.receiver
          end

          unsafe_method_calls.each do |unsafe_method_call|
            location =
              node.loc.expression.join(unsafe_method_call.loc.expression)
            add_offense(unsafe_method_call,
                        location: location)
          end
        end

        def autocorrect(node)
          return unless node.dot?

          lambda do |corrector|
            corrector.insert_before(node.loc.dot, '&')
          end
        end

        private

        def top_conditional_ancestor(node)
          parent = node.parent
          unless parent &&
                 (AST::Node::OPERATOR_KEYWORDS.include?(parent.type) ||
                  (parent.begin_type? &&
                   AST::Node::OPERATOR_KEYWORDS.include?(parent.parent.type)))
            return node
          end
          top_conditional_ancestor(parent)
        end
      end
    end
  end
end
