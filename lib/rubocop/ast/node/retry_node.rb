# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `retry` nodes. This will be used in place of a
    # plain node when the builder constructs the AST, making its methods
    # available to all `retry` nodes within RuboCop.
    class RetryNode < Node
      include MethodDispatchNode
      include ParameterizedNode

      def arguments
        []
      end
    end
  end
end
