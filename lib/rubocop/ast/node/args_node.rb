# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `args` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `args` nodes within RuboCop.
    class ArgsNode < Node
      include CollectionNode
    end
  end
end
