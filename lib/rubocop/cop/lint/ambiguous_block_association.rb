# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for ambiguous block association with method
      # when param passed without parentheses.
      #
      # @example
      #
      #   # bad
      #
      #   # It's ambiguous because there is no parentheses around `a` param
      #   some_method a { |val| puts val }
      #
      # @example
      #
      #   # good
      #
      #   # With parentheses, there's no ambiguity.
      #   some_method(a) { |val| puts val }
      class AmbiguousBlockAssociation < Cop
        MSG = 'Parenthesize the param to make sure that block will be '\
              'associated with method call.'.freeze

        def on_send(node)
          return unless node.arguments?

          first_argument = node.arguments.first
          return unless first_argument.block_type?

          first_child = first_argument.children.first
          return unless first_child.is_a?(RuboCop::AST::Node)
          return unless first_child.send_type?

          add_offense(node, :expression)
        end
      end
    end
  end
end
