# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for top level return with arguments. If there is a
      # top-level return statement with an argument, then the argument is
      # always ignored. This is detected automatically since Ruby 2.7.
      #
      # This cop works by validating the ancestors of the return node. A
      # top-level return node's ancestors satisfy either of the conditions:
      #
      # 1. The parent should be `nil`.
      # 2. The parent should be an instance of `AST::Node` & the parent.parent
      #    is `nil`.
      #
      # Case 1 occurs in cases where the top-level return statement is the
      # only piece of code in the whole file. It being the only statement,
      # the statement does not have a parent, like so:
      #
      #   return 1, 2, 3
      #
      # Case 2 occurs in cases where the file contains statements other than
      # just the top-level return statement. In such cases, the parent is of
      # the type `AST::Node` and the parent.parent is `nil`, like so:
      #
      #   foo
      #
      #   return 1, 2, 3 # Allowed since Ruby 2.4.
      #
      #   bar
      #
      # All other return statements are usually defined inside a method, or in
      # a block. Thus, unlike the top-level return, these statements have
      # parents belonging to the `AST::DefNode`, `AST::BlockNode` or
      # `AST::IfNode` class.
      #
      # @example
      #
      #   # Detected since Ruby 2.7
      #   return 1 # 1 is always ignored.
      class TopLevelReturnWithArgument < Cop
        MSG = 'Top level return with argument detected.'

        def on_return(return_node)
          add_offense(return_node) if ancestors_valid?(return_node) && !return_node.arguments.empty?
        end

        private

        def ancestors_valid?(return_node)
          return true if return_node.parent.nil?

          if return_node.parent.instance_of?(AST::Node) && return_node.parent.parent.nil?
            return true
          end

          false
        end
      end
    end
  end
end
