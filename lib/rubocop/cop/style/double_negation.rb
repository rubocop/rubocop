# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of double negation (!!) to convert something
      # to a boolean value. As this is both cryptic and usually redundant, it
      # should be avoided.
      #
      # @example
      #
      #   # bad
      #   !!something
      #
      #   # good
      #   !something.nil?
      #
      # Please, note that when something is a boolean value
      # !!something and !something.nil? are not the same thing.
      # As you're unlikely to write code that can accept values of any type
      # this is rarely a problem in practice.
      class DoubleNegation < Cop
        MSG = 'Avoid the use of double negation (`!!`).'

        def on_send(node)
          return unless not_node?(node)

          receiver, _method_name, *_args = *node

          add_offense(node, :selector) if not_node?(receiver)
        end

        private

        def not_node?(node)
          _receiver, method_name, *args = *node

          # ! does not take any arguments
          args.empty? && method_name == :! &&
            node.loc.selector.is?('!')
        end
      end
    end
  end
end
