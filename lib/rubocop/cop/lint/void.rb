# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for operators, variables and literals used
      # in void context.
      class Void < Cop
        OP_MSG = 'Operator %s used in void context.'
        VAR_MSG = 'Variable %s used in void context.'
        LIT_MSG = 'Literal %s used in void context'

        OPS = %w(* / % + - == === != < > <= >= <=>)
        VARS = [:ivar, :lvar, :cvar, :const]
        LITERALS = [:str, :dstr, :int, :float, :array,
                    :hash, :regexp, :nil, :true, :false]

        def on_begin(node)
          expressions = *node

          expressions.drop_last(1).each do |expr|
            check_for_void_op(expr)
            check_for_literal(expr)
            check_for_var(expr)
          end
        end

        private

        def check_for_void_op(node)
          return unless node.type == :send

          op = node.loc.selector.source

          add_offence(node, :selector, sprintf(OP_MSG, op)) if OPS.include?(op)
        end

        def check_for_var(node)
          if VARS.include?(node.type)
            add_offence(node, :name,
                        sprintf(VAR_MSG, node.loc.name.source))
          end
        end

        def check_for_literal(node)
          if LITERALS.include?(node.type)
            add_offence(node, :expression,
                        sprintf(LIT_MSG, node.loc.expression.source))
          end
        end
      end
    end
  end
end
