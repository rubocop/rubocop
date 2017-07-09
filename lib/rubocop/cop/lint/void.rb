# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for operators, variables and literals used
      # in void context.
      #
      # @example
      #
      #   # bad
      #
      #   def some_method
      #     some_num * 10
      #     do_something
      #   end
      #
      # @example
      #
      #   # bad
      #
      #   def some_method(some_var)
      #     some_var
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method
      #     do_something
      #     some_num * 10
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method(some_var)
      #     do_something
      #     some_var
      #   end
      class Void < Cop
        OP_MSG = 'Operator `%s` used in void context.'.freeze
        VAR_MSG = 'Variable `%s` used in void context.'.freeze
        LIT_MSG = 'Literal `%s` used in void context.'.freeze
        SELF_MSG = '`self` used in void context.'.freeze
        DEFINED_MSG = '`%s` used in void context.'.freeze

        BINARY_OPERATORS = %i[* / % + - == === != < > <= >= <=>].freeze
        UNARY_OPERATORS = %i[+@ -@ ~ !].freeze
        OPERATORS = (BINARY_OPERATORS + UNARY_OPERATORS).freeze
        VOID_CONTEXT_TYPES = %i[def for block].freeze

        def on_begin(node)
          check_begin(node)
        end
        alias on_kwbegin on_begin

        private

        def check_begin(node)
          expressions = *node
          expressions = expressions.drop_last(1) unless in_void_context?(node)
          expressions.each do |expr|
            check_void_op(expr)
            check_literal(expr)
            check_var(expr)
            check_self(expr)
            check_defined(expr)
          end
        end

        def check_void_op(node)
          return unless node.send_type? && OPERATORS.include?(node.method_name)

          add_offense(node, :selector, format(OP_MSG, node.method_name))
        end

        def check_var(node)
          return unless node.variable? || node.const_type?
          add_offense(node, :name, format(VAR_MSG, node.loc.name.source))
        end

        def check_literal(node)
          return if !node.literal? || node.xstr_type?

          add_offense(node, :expression, format(LIT_MSG, node.source))
        end

        def check_self(node)
          return unless node.self_type?

          add_offense(node, :expression, SELF_MSG)
        end

        def check_defined(node)
          return unless node.defined_type?

          add_offense(node, :expression, format(DEFINED_MSG, node.source))
        end

        def in_void_context?(node)
          parent = node.parent

          return false unless parent && parent.children.last == node

          VOID_CONTEXT_TYPES.include?(parent.type) && parent.void_context?
        end
      end
    end
  end
end
