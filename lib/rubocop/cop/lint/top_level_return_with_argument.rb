# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for top level return with arguments. If there is a
      # top-level return statement with an argument, then the argument is
      # always ignored. This is detected automatically since Ruby 2.7.
      #
      # This cop works by validating the ancestors of the return node. A
      # top-level return node's ancestors will never belong to `AST::BlockNode`
      # or `AST::DefNode` class.
      #
      # @example
      #
      #   # Detected since Ruby 2.7
      #   return 1 # 1 is always ignored.
      class TopLevelReturnWithArgument < Cop
        MSG = 'Top level return with argument detected.'

        def on_return(return_node)
          add_offense(return_node) if ancestors_valid?(return_node) && return_node.arguments?
        end

        private

        def ancestors_valid?(return_node)
          prohibited_ancestors = return_node.each_ancestor(:block, :def, :defs)
          return false if prohibited_ancestors.any?

          true
        end
      end
    end
  end
end
