# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for operators, variables, literals, lambda, proc and nonmutating
      # methods used in void context.
      #
      # `each` blocks are allowed to prevent false positives.
      # For example, the expression inside the `each` block below.
      # It's not void, especially when the receiver is an `Enumerator`:
      #
      # [source,ruby]
      # ----
      # enumerator = [1, 2, 3].filter
      # enumerator.each { |item| item >= 2 } #=> [2, 3]
      # ----
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
        extend AutoCorrector

        include RangeHelp

        OP_MSG = 'Operator `%<op>s` used in void context.'
        VAR_MSG = 'Variable `%<var>s` used in void context.'
        CONST_MSG = 'Constant `%<var>s` used in void context.'
        LIT_MSG = 'Literal `%<lit>s` used in void context.'
        SELF_MSG = '`self` used in void context.'
        EXPRESSION_MSG = '`%<expression>s` used in void context.'
        NONMUTATING_MSG = 'Method `#%<method>s` used in void context. Did you mean `#%<suggest>s`?'

        BINARY_OPERATORS = %i[* / % + - == === != < > <= >= <=>].freeze
        UNARY_OPERATORS = %i[+@ -@ ~ !].freeze
        OPERATORS = (BINARY_OPERATORS + UNARY_OPERATORS).freeze
        VOID_CONTEXT_TYPES = %i[def for block].freeze
        NONMUTATING_METHODS_WITH_BANG_VERSION = %i[capitalize chomp chop compact
                                                   delete_prefix delete_suffix downcase
                                                   encode flatten gsub lstrip merge next
                                                   reject reverse rotate rstrip scrub select
                                                   shuffle slice sort sort_by squeeze strip sub
                                                   succ swapcase tr tr_s transform_values
                                                   unicode_normalize uniq upcase].freeze
        METHODS_REPLACEABLE_BY_EACH = %i[collect map].freeze

        NONMUTATING_METHODS = (NONMUTATING_METHODS_WITH_BANG_VERSION +
                               METHODS_REPLACEABLE_BY_EACH).freeze

        def on_block(node)
          return unless node.body && !node.body.begin_type?
          return unless in_void_context?(node.body)

          check_void_op(node.body) { node.method?(:each) }
          check_expression(node.body)
        end

        alias on_numblock on_block

        def on_begin(node)
          check_begin(node)
        end
        alias on_kwbegin on_begin

        private

        def check_begin(node)
          expressions = *node
          expressions.pop unless in_void_context?(node)
          expressions.each do |expr|
            check_void_op(expr)
            check_expression(expr)
          end
        end

        def check_expression(expr)
          check_literal(expr)
          check_var(expr)
          check_self(expr)
          check_void_expression(expr)
          return unless cop_config['CheckForMethodsWithNoSideEffects']

          check_nonmutating(expr)
        end

        def check_void_op(node, &block)
          return unless node.send_type? && OPERATORS.include?(node.method_name)
          return if block && yield(node)

          add_offense(node.loc.selector,
                      message: format(OP_MSG, op: node.method_name)) do |corrector|
            autocorrect_void_op(corrector, node)
          end
        end

        def check_var(node)
          return unless node.variable? || node.const_type?

          if node.const_type?
            template = node.special_keyword? ? VAR_MSG : CONST_MSG

            offense_range = node
            message = format(template, var: node.source)
          else
            offense_range = node.loc.name
            message = format(VAR_MSG, var: node.loc.name.source)
          end

          add_offense(offense_range, message: message) do |corrector|
            autocorrect_void_expression(corrector, node)
          end
        end

        def check_literal(node)
          return if !node.literal? || node.xstr_type? || node.range_type?

          add_offense(node, message: format(LIT_MSG, lit: node.source)) do |corrector|
            autocorrect_void_expression(corrector, node)
          end
        end

        def check_self(node)
          return unless node.self_type?

          add_offense(node, message: SELF_MSG) do |corrector|
            autocorrect_void_expression(corrector, node)
          end
        end

        def check_void_expression(node)
          return unless node.defined_type? || node.lambda_or_proc?

          add_offense(node, message: format(EXPRESSION_MSG, expression: node.source)) do |corrector|
            autocorrect_void_expression(corrector, node)
          end
        end

        def check_nonmutating(node)
          return if !node.send_type? && !node.block_type? && !node.numblock_type?

          method_name = node.method_name
          return unless NONMUTATING_METHODS.include?(method_name)

          suggestion = if METHODS_REPLACEABLE_BY_EACH.include?(method_name)
                         'each'
                       else
                         "#{method_name}!"
                       end
          add_offense(node,
                      message: format(NONMUTATING_MSG, method: method_name,
                                                       suggest: suggestion)) do |corrector|
            autocorrect_nonmutating_send(corrector, node, suggestion)
          end
        end

        def in_void_context?(node)
          parent = node.parent

          return false unless parent && parent.children.last == node

          VOID_CONTEXT_TYPES.include?(parent.type) && parent.void_context?
        end

        def autocorrect_void_op(corrector, node)
          if node.arguments.empty?
            corrector.replace(node, node.receiver.source)
          else
            corrector.replace(
              range_with_surrounding_space(range: node.loc.selector, side: :both,
                                           newlines: false),
              "\n"
            )
          end
        end

        def autocorrect_void_expression(corrector, node)
          corrector.remove(range_with_surrounding_space(range: node.source_range, side: :left))
        end

        def autocorrect_nonmutating_send(corrector, node, suggestion)
          send_node = if node.send_type?
                        node
                      else
                        node.send_node
                      end
          corrector.replace(send_node.loc.selector, suggestion)
        end
      end
    end
  end
end
