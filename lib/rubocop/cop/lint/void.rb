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
      #   def some_method
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
      #   def some_method
      #     do_something
      #     some_var
      #   end
      class Void < Cop
        OP_MSG = 'Operator `%s` used in void context.'.freeze
        VAR_MSG = 'Variable `%s` used in void context.'.freeze
        LIT_MSG = 'Literal `%s` used in void context.'.freeze
        SELF_MSG = '`self` used in void context.'.freeze
        DEFINED_MSG = '`%s` used in void context.'.freeze

        OPS = %w[* / % + - == === != < > <= >= <=>].freeze

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
            check_for_self(expr)
            check_for_defined(expr)
          end
        end

        def check_for_void_op(node)
          return unless node.send_type? && node.loc.selector

          op = node.loc.selector.source

          add_offense(node, :selector, format(OP_MSG, op)) if OPS.include?(op)
        end

        def check_for_var(node)
          return unless node.variable? || node.const_type?
          add_offense(node, :name, format(VAR_MSG, node.loc.name.source))
        end

        def check_for_literal(node)
          return if !node.literal? || node.xstr_type?

          add_offense(node, :expression, format(LIT_MSG, node.source))
        end

        def check_for_self(node)
          return unless node.self_type?

          add_offense(node, :expression, SELF_MSG)
        end

        def check_for_defined(node)
          return unless node.defined_type?

          add_offense(node, :expression, format(DEFINED_MSG, node.source))
        end
      end
    end
  end
end
