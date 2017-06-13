# frozen_string_literal: true

module RuboCop
  module AST
    # Common functionality for nodes that are parameterized:
    # `send`, `super`, `zsuper`, `def`, `defs`
    module ParameterizedNode
      # Checks whether this node's arguments are wrapped in parentheses.
      #
      # @return [Boolean] whether this node's arguments are
      #                   wrapped in parentheses
      def parenthesized?
        loc.end && loc.end.is?(')')
      end

      # A shorthand for getting the first argument of the node.
      # Equivalent to `arguments.first`.
      #
      # @return [Node, nil] the first argument of the node,
      #                     or `nil` if there are no arguments
      def first_argument
        arguments[0]
      end

      # A shorthand for getting the last argument of the node.
      # Equivalent to `arguments.last`.
      #
      # @return [Node, nil] the last argument of the node,
      #                     or `nil` if there are no arguments
      def last_argument
        arguments[-1]
      end

      # Checks whether this node has any arguments.
      #
      # @return [Boolean] whether this node has any arguments
      def arguments?
        !arguments.empty?
      end

      # Checks whether any argument of the node is a splat
      # argument, i.e. `*splat`.
      #
      # @return [Boolean] whether the node is a splat argument
      def splat_argument?
        arguments? &&
          (arguments.any?(&:splat_type?) || arguments.any?(&:restarg_type?))
      end
      alias rest_argument? splat_argument?

      # Whether the last argument of the node is a block pass,
      # i.e. `&block`.
      #
      # @return [Boolean] whether the last argument of the node is a block pass
      def block_argument?
        arguments? &&
          (last_argument.block_pass_type? || last_argument.blockarg_type?)
      end
    end
  end
end
