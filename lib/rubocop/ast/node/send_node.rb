# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `send` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `send` nodes within RuboCop.
    class SendNode < Node
      include ParameterizedNode
      include MethodDispatchNode

      # Checks whether this is a lambda. Some versions of parser parses
      # non-literal lambdas as a method send.
      #
      # @return [Boolean] whether this method is a lambda
      def lambda?
        block_literal? && method?(:lambda)
      end

      # Checks whether this is a stabby lambda. e.g. `-> () {}`
      #
      # @return [Boolean] whether this method is a stabby lambda
      def stabby_lambda?
        loc.selector && loc.selector.source == '->'
      end
    end
  end
end
