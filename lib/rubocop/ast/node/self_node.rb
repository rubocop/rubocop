# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `self` nodes. This will be used in place of a
    # plain node when the builder constructs the AST, making its methods
    # available to all `self` nodes within RuboCop.
    class SelfNode < Node
      include MethodIdentifierPredicates

      # Always return `false` because `self` cannot have arguments.
      def arguments?
        false
      end
    end
  end
end
