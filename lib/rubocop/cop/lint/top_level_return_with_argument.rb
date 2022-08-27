# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for top level return with arguments. If there is a
      # top-level return statement with an argument, then the argument is
      # always ignored. This is detected automatically since Ruby 2.7.
      #
      # @example
      #
      #   # Detected since Ruby 2.7
      #   return 1 # 1 is always ignored.
      class TopLevelReturnWithArgument < Base
        # This cop works by validating the ancestors of the return node. A
        # top-level return node's ancestors should not be of block, def, or
        # defs type.

        MSG = 'Top level return with argument detected.'

        def on_return(return_node)
          add_offense(return_node) if return_node.arguments? && ancestors_valid?(return_node)
        end

        private

        def ancestors_valid?(return_node)
          prohibited_ancestors = return_node.each_ancestor(:block, :def, :defs)
          prohibited_ancestors.none?
        end
      end
    end
  end
end
