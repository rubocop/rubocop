# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for operators, variables, literals, and nonmutating
      # methods used in void context.
      #
      # @example CheckForMethodsWithNoSideEffects: false (default)
      #   # bad
      #   def some_method
      #     some_num * 10
      #     do_something
      #   end
      #
      #   def some_method(some_var)
      #     some_var
      #     do_something
      #   end
      #
      # @example CheckForMethodsWithNoSideEffects: true
      #   # bad
      #   def some_method(some_array)
      #     some_array.sort
      #     do_something(some_array)
      #   end
      #
      #   # good
      #   def some_method
      #     do_something
      #     some_num * 10
      #   end
      #
      #   def some_method(some_var)
      #     do_something
      #     some_var
      #   end
      #
      #   def some_method(some_array)
      #     some_array.sort!
      #     do_something(some_array)
      #   end
      class Void < Base
        OP_MSG = 'Operator `%<op>s` used in void context.'
        VAR_MSG = 'Variable `%<var>s` used in void context.'
        LIT_MSG = 'Literal `%<lit>s` used in void context.'
        SELF_MSG = '`self` used in void context.'
        DEFINED_MSG = '`%<defined>s` used in void context.'
        NONMUTATING_MSG = 'Method `#%<method>s` used in void context. Did you mean `#%<method>s!`?'

        BINARY_OPERATORS = %i[* / % + - == === != < > <= >= <=>].freeze
        UNARY_OPERATORS = %i[+@ -@ ~ !].freeze
        OPERATORS = (BINARY_OPERATORS + UNARY_OPERATORS).freeze
        VOID_CONTEXT_TYPES = %i[def for block].freeze
        NONMUTATING_METHODS = %i[capitalize chomp chop collect compact
                                 delete_prefix delete_suffix downcase
                                 encode flatten gsub lstrip map merge next
                                 reject reverse rotate rstrip scrub select
                                 shuffle slice sort sort_by squeeze strip sub
                                 succ swapcase tr tr_s transform_values
                                 unicode_normalize uniq upcase].freeze

        def on_block(node)
          return unless node.body && !node.body.begin_type?
          return unless in_void_context?(node.body)

          check_expression(node.body)
        end

        def on_begin(node)
          check_begin(node)
        end
        alias on_kwbegin on_begin

        private

        def check_begin(node)
          expressions = *node
          expressions.pop unless in_void_context?(node)
          expressions.each { |expr| check_expression(expr) }
        end

        def check_expression(expr)
          check_void_op(expr)
          check_literal(expr)
          check_var(expr)
          check_self(expr)
          check_defined(expr)
          return unless cop_config['CheckForMethodsWithNoSideEffects']

          check_nonmutating(expr)
        end

        def check_void_op(node)
          return unless node.send_type? && OPERATORS.include?(node.method_name)

          add_offense(node.loc.selector, message: format(OP_MSG, op: node.method_name))
        end

        def check_var(node)
          return unless node.variable? || node.const_type?

          add_offense(node.loc.name, message: format(VAR_MSG, var: node.loc.name.source))
        end

        def check_literal(node)
          return if !node.literal? || node.xstr_type? || node.range_type?

          add_offense(node, message: format(LIT_MSG, lit: node.source))
        end

        def check_self(node)
          return unless node.self_type?

          add_offense(node, message: SELF_MSG)
        end

        def check_defined(node)
          return unless node.defined_type?

          add_offense(node, message: format(DEFINED_MSG, defined: node.source))
        end

        def check_nonmutating(node)
          return unless node.send_type? && NONMUTATING_METHODS.include?(node.method_name)

          add_offense(node, message: format(NONMUTATING_MSG, method: node.method_name))
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
