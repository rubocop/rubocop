# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the use of a return with a value in a context
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
      # @example
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
      class ReturnInVoidContext < Cop
        MSG = 'Do not return a value in `%s`.'.freeze

        def on_return(return_node)
          return unless return_node.descendants.any?

          context_node = non_void_context(return_node)

          return unless context_node && context_node.def_type?

          method_name = method_name(context_node)

          return unless method_name && void_context_method?(method_name)

          add_offense(return_node,
                      location: :keyword,
                      message: format(message, method_name))
        end

        private

        def non_void_context(return_node)
          return_node.each_ancestor(:block, :def, :defs).first
        end

        def method_name(context_node)
          context_node.children.first
        end

        def void_context_method?(method_name)
          method_name == :initialize || setter_method?(method_name)
        end

        def setter_method?(method_name)
          method_name.to_s.end_with?('=') &&
            !AST::Node::COMPARISON_OPERATORS.include?(method_name)
        end
      end
    end
  end
end
