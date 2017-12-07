# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `send` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `send` nodes within RuboCop.
    class SendNode < Node
      include ParameterizedNode
      include MethodDispatchNode
      ARROW = '->'.freeze

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array] the different parts of the `send` node
      def node_parts
        to_a
      end

      # Checks whether this is a negation method, i.e. `!` or keyword `not`.
      #
      # @return [Boolean] whether this method is a negation method
      def negation_method?
        keyword_bang? || keyword_not?
      end

      # Checks whether this is a lambda. Some versions of parser parses
      # non-literal lambdas as a method send.
      #
      # @return [Boolean] whether this method is a lambda
      def lambda?
        parent && parent.block_type? && method?(:lambda)
      end

      # Checks whether this is a stabby lambda. e.g. `-> () {}`
      #
      # @return [Boolean] whether this method is a staby lambda
      def stabby_lambda?
        selector = loc.selector
        selector && selector.source == ARROW
      end
    end
  end
end
