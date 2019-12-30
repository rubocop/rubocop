# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `forward-args` nodes. This will be used in place
    # of a plain node when the builder constructs the AST, making its methods
    # available to all `forward-args` nodes within RuboCop.
    class ForwardArgsNode < Node
      include CollectionNode

      # Node wraps itself in an array to be compatible with other
      # enumerable argument types.
      def to_a
        [self]
      end
    end
  end
end
