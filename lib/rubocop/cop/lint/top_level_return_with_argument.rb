# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for top level return with arguments. If there is a
      # top-level return statement with an argument, then the argument is
      # always ignored. This is detected automatically in Ruby 2.7 and up,
      # but RuboCop doesn't detect it yet.
      #
      # @example
      #   foo
      #
      #   return # Allowed since Ruby 2.4.
      #
      #   bar
      #
      #   # Detected since Ruby 2.7
      #   return 1 # 1 is always ignored.
      class TopLevelReturnWithArgument < Cop
        MSG = 'Top level return with argument detected.'

        def on_return(return_node)
          if return_node.parent.instance_of?(RuboCop::AST::Node) && !return_node.arguments.empty?
            add_offense(return_node)
          end
        end
      end
    end
  end
end
