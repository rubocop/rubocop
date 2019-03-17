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
        MSG = 'Parenthesize the param `%<param>s` to make sure that the ' \
              'block will be associated with the `%<method>s` method ' \
              'call.'.freeze

        def on_send(node)
          return if !node.arguments? || node.parenthesized? ||
                    node.last_argument.lambda? || allowed_method?(node)

          return unless ambiguous_block_association?(node)

          add_offense(node)
        end
        alias on_csend on_send

        private

        def ambiguous_block_association?(send_node)
          send_node.last_argument.block_type? &&
            !send_node.last_argument.send_node.arguments?
        end

        def allowed_method?(node)
          node.assignment? || node.operator_method? || node.method?(:[])
        end

        def message(send_node)
          block_param = send_node.last_argument

          format(MSG, param: block_param.source,
                      method: block_param.send_node.source)
        end
      end
    end
  end
end
