# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for operators, variables and literals used
      # in void context.
      class Void < Cop
        OP_MSG = 'Operator `%s` used in void context.'
        VAR_MSG = 'Variable `%s` used in void context.'
        LIT_MSG = 'Literal `%s` used in void context.'

        OPS = %w(* / % + - == === != < > <= >= <=>)
        VARS = [:ivar, :lvar, :cvar, :const]
        LITERALS = [:str, :dstr, :int, :float, :array,
                    :hash, :regexp, :nil, :true, :false, :sym]

        def on_begin(node)
          check_begin(node)
        end

        def on_kwbegin(node)
          check_begin(node)
        end

        private

        def check_begin(node)
          expressions = *node

          expressions.drop_last(1).each do |expr|
            check_for_void_op(expr)
            check_for_literal(expr)
            check_for_var(expr)
          end
        end

        def check_for_void_op(node)
          return unless node.type == :send
          return unless node.loc.selector

          op = node.loc.selector.source

          add_offense(node, :selector, format(OP_MSG, op)) if OPS.include?(op)
        end

        def check_for_var(node)
          return unless VARS.include?(node.type)
          add_offense(node, :name, format(VAR_MSG, node.loc.name.source))
        end

        def check_for_literal(node)
          return unless LITERALS.include?(node.type)
          add_offense(node, :expression,
                      format(LIT_MSG, node.loc.expression.source))
        end
      end
    end
  end
end
