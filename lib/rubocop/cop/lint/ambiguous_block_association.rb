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
      #
      #   # good
      #   # Operator methods require no disambiguation
      #   foo == bar { |b| b.baz }
      #
      #   # good
      #   # Lambda arguments require no disambiguation
      #   foo = ->(bar) { bar.baz }
      class AmbiguousBlockAssociation < Cop
        MSG = 'Parenthesize the param `%s` to make sure that the block will be'\
              ' associated with the `%s` method call.'.freeze

        def on_send(node)
          return if node.parenthesized? || allowed_method?(node)
          return if lambda_argument?(node.first_argument)

          return unless method_with_block?(node.first_argument)
          first_param = node.first_argument.children.first
          return unless method_as_param?(first_param)

          add_offense(node, :expression, message(first_param, node.method_name))
        end

        private

        def allowed_method?(node)
          node.assignment? || node.operator_method? || node.method?(:[])
        end

        def method_with_block?(param)
          param && param.block_type?
        end

        def method_as_param?(param)
          param && param.send_type? && !param.arguments?
        end

        def message(param, method_name)
          format(MSG, param.children[1], method_name)
        end

        def_node_matcher :lambda_argument?, <<-PATTERN
          (block (send _ :lambda) ...)
        PATTERN
      end
    end
  end
end
