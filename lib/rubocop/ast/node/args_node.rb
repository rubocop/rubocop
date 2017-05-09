# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `args` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `send` nodes within RuboCop.
    class ArgsNode < Node
      # Whether this `args` node has any arguments.
      #
      # @return [Boolean] whether this `args` node has any arguments
      def empty?
        to_a.empty?
      end

      # The number of arguments in this `args` node.
      #
      # @return [Integer] the number of arguments in this `args` node
      def size
        to_a.size
      end
    end
  end
end
