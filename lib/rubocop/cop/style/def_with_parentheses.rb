# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for parentheses in the definition of a method,
      # that does not take any arguments. Both instance and
      # class/singleton methods are checked.
      #
      # @example
      #
      #   # bad
      #   def foo()
      #     # does a thing
      #   end
      #
      #   # good
      #   def foo
      #     # does a thing
      #   end
      #
      #   # also good
      #   def foo() does_a_thing end
      #
      # @example
      #
      #   # bad
      #   def Baz.foo()
      #     # does a thing
      #   end
      #
      #   # good
      #   def Baz.foo
      #     # does a thing
      #   end
      class DefWithParentheses < Base
        extend AutoCorrector

        MSG = "Omit the parentheses in defs when the method doesn't accept " \
              'any arguments.'

        def on_def(node)
          return if node.single_line?
          return unless !node.arguments? && (node_arguments_loc_begin = node.arguments.loc.begin)

          add_offense(node_arguments_loc_begin) do |corrector|
            corrector.remove(node_arguments_loc_begin)
            corrector.remove(node.arguments.loc.end)
          end
        end
        alias on_defs on_def
      end
    end
  end
end
