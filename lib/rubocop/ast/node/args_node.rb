# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `args` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `args` nodes within RuboCop.
    class ArgsNode < Node
      include CollectionNode

      # It returns true if arguments are empty and delimiters do not exist.
      # @example:
      #   # true
      #   def x; end
      #   x { }
      #   -> {}
      #
      #   # false
      #   def x(); end
      #   def x a; end
      #   x { || }
      #   -> () {}
      #   -> a {}
      def empty_and_without_delimiters?
        loc.expression.nil?
      end
    end
  end
end
