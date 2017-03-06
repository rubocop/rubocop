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
      #   some_method a { |val| puts val }
      #
      # @example
      #
      #   # good
      #   # With parentheses, there's no ambiguity.
      #   some_method(a) { |val| puts val }
      class AmbiguousBlockAssociation < Cop
        MSG = 'Parenthesize the param `%s` to make sure that the block will be'\
              ' associated with the `%s` method call.'.freeze

        def on_send(node)
          return if node.parenthesized? || node.assignment? || node.method?(:[])

          return unless method_with_block?(node.first_argument)
          first_param = node.first_argument.children.first
          return unless method_as_param?(first_param)

          add_offense(
            node, :expression, format_error(first_param, node.method_name)
          )
        end

        private

        def method_with_block?(param)
          return false unless param

          param.block_type?
        end

        def method_as_param?(param)
          return false unless param.is_a?(RuboCop::AST::Node)

          param.send_type? && !param.arguments?
        end

        def format_error(param, method_name)
          format(MSG, param.children[1], method_name)
        end
      end
    end
  end
end
