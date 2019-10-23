# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `return` nodes. This will be used in place of a
    # plain node when the builder constructs the AST, making its methods
    # available to all `return` nodes within RuboCop.
    class ReturnNode < Node
      include MethodDispatchNode
      include ParameterizedNode

      # Returns the arguments of the `return`.
      #
      # @return [Array] The arguments of the `return`.
      def arguments
        if node_parts.one? && node_parts.first.begin_type?
          node_parts.first.children
        else
          node_parts
        end
      end
    end
  end
end
