# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `send` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `send` nodes within RuboCop.
    class SendNode < Node
      include ParameterizedNode
      include MethodDispatchNode

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array] the different parts of the `send` node
      def node_parts
        to_a
      end

      def negation_method?
        keyword_bang? || keyword_not?
      end
    end
  end
end
