# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of double negation (!!) to convert something
      # to a boolean value. As this is both cryptic and usually redundant it
      # should be avoided.
      #
      # @example
      #
      #   # bad
      #   !!something
      #
      #   # good
      #   !something.nil?
      class DoubleNegation < Cop
        MSG = 'Avoid the use of double negation (!!).'

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
