# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the use of a return with a value in a context
      # where it the value will be ignored. (initialize and setter methods)
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
      #  # good
      #   def initialize
      #     foo
      #     return if bar?
      #     baz
      #   end
      #
      #   def foo=(bar)
      #     return
      #   end
      #
      class ReturnInVoidContext < Cop
        MSG = 'Do not return a value in `%s`.'.freeze
        def on_return(return_node)
          method_name = method_name(return_node)
          return unless method_name && return_node.descendants.any? &&
                        useless_return_method?(method_name)

          add_offense(return_node, :keyword, format(message, method_name))
        end

        private

        def method_name(return_node)
          method_node = return_node.each_ancestor(:block, :def, :defs).first
          return nil unless method_node.type == :def
          method_node.children.first
        end

        def method_setter?(method_name)
          method_name.to_s.end_with?('=') &&
            !%i[!= == === >= <=].include?(method_name)
        end

        def useless_return_method?(method_name)
          method_name == :initialize || method_setter?(method_name)
        end
      end
    end
  end
end
