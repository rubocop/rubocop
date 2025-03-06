# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for the use of a return with a value in a context
      # where the value will be ignored. (initialize and setter methods)
      #
      # @example
      #
      #   # bad
      #   def initialize
      #     foo
      #     return :qux if bar?
      #     baz
      #   end
      #
      #   def foo=(bar)
      #     return 42
      #   end
      #
      #   # good
      #   def initialize
      #     foo
      #     return if bar?
      #     baz
      #   end
      #
      #   def foo=(bar)
      #     return
      #   end
      class ReturnInVoidContext < Base
        MSG = 'Do not return a value in `%<method>s`.'

        def on_return(return_node)
          return unless return_node.descendants.any?

          def_node = return_node.each_ancestor(:def).first
          return unless def_node&.void_context?
          return if return_node.each_ancestor(:any_block).any?(&:lambda?)

          add_offense(
            return_node.loc.keyword,
            message: format(message, method: def_node.method_name)
          )
        end
      end
    end
  end
end
