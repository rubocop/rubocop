# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `super`- and `zsuper` nodes. This will be used in
    # place of a plain node when the builder constructs the AST, making its
    # methods available to all `super`- and `zsuper` nodes within RuboCop.
    class SuperNode < Node
      include ParameterizedNode

      # The method name of this `super` node. Always `:super`.
      #
      # @return [Symbol] the method name of `super`
      def method_name
        :super
      end

      # An array containing the arguments of the super invocation.
      #
      # @return [Array<Node>] the arguments of the super invocation
      def arguments
        node_parts
      end

      # Checks whether the method name matches the argument.
      #
      # @param [Symbol, String] name the method name to check for
      # @return [Boolean] whether the method name matches the argument
      def method?(name)
        method_name == name.to_sym
      end

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array] the different parts of the `block` node
      def node_parts
        to_a
      end
    end
  end
end
