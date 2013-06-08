# encoding: utf-8

module Rubocop
  module Cop
    class Void < Cop
      OP_MSG = 'Operator %s used in void context.'
      VAR_MSG = 'Variable %s used in void context.'
      LIT_MSG = 'Literal %s used in void context'

      OPS = %w(* / % + - == === != < > <= >= <=>)
      VARS = [:ivar, :lvar, :cvar, :const]
      LITERALS = [:str, :dstr, :int, :float, :array, :hash, :regexp]

      def on_begin(node)
        expressions = *node

        expressions[0...-1].each do |expr|
          check_for_void_op(expr)
          check_for_literal(expr)
          check_for_var(expr)
        end

        super
      end

      private

      def check_for_void_op(node)
        return unless node.type == :send

        op = node.loc.selector.source

        if OPS.include?(op)
          add_offence(:warning, node.loc.selector, sprintf(OP_MSG, op))
        end
      end

      def check_for_var(node)
        if VARS.include?(node.type)
          add_offence(:warning, node.loc.name,
                      sprintf(VAR_MSG, node.loc.name.source))
        end
      end

      def check_for_literal(node)
        if LITERALS.include?(node.type)
          add_offence(:warning, node.loc.expression,
                      sprintf(LIT_MSG, node.loc.expression.source))
        end
      end
    end
  end
end
