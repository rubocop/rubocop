# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for ambiguous block association with method
      # when param passed without parentheses.
      #
      # This cop can customize allowed methods with `AllowedMethods`.
      # By default, there are no methods to allowed.
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
      #   some_method(a { |val| puts val })
      #   # or (different meaning)
      #   some_method(a) { |val| puts val }
      #
      #   # good
      #   # Operator methods require no disambiguation
      #   foo == bar { |b| b.baz }
      #
      #   # good
      #   # Lambda arguments require no disambiguation
      #   foo = ->(bar) { bar.baz }
      #
      # @example AllowedMethods: [] (default)
      #
      #   # bad
      #   expect { do_something }.to change { object.attribute }
      #
      # @example AllowedMethods: [change]
      #
      #   # good
      #   expect { do_something }.to change { object.attribute }
      #
      # @example AllowedPatterns: [] (default)
      #
      #   # bad
      #   expect { do_something }.to change { object.attribute }
      #
      # @example AllowedPatterns: [/change/]
      #
      #   # good
      #   expect { do_something }.to change { object.attribute }
      #   expect { do_something }.to not_change { object.attribute }
      #
      class AmbiguousBlockAssociation < Base
        include AllowedMethods
        include AllowedPattern

        MSG = 'Parenthesize the param `%<param>s` to make sure that the ' \
              'block will be associated with the `%<method>s` method ' \
              'call.'

        def on_send(node)
          return unless node.arguments?

          return unless ambiguous_block_association?(node)
          return if node.parenthesized? || node.last_argument.lambda? || node.last_argument.proc? ||
                    allowed_method_pattern?(node)

          message = message(node)

          add_offense(node, message: message)
        end
        alias on_csend on_send

        private

        def ambiguous_block_association?(send_node)
          send_node.last_argument.block_type? && !send_node.last_argument.send_node.arguments?
        end

        def allowed_method_pattern?(node)
          node.assignment? || node.operator_method? || node.method?(:[]) ||
            allowed_method?(node.last_argument.method_name) ||
            matches_allowed_pattern?(node.last_argument.method_name)
        end

        def message(send_node)
          block_param = send_node.last_argument

          format(MSG, param: block_param.source, method: block_param.send_node.source)
        end
      end
    end
  end
end
