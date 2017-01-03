# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `if` expressions that do not have an `else` branch.
      # SupportedStyles
      #
      # if
      # @example
      #   # bad
      #   if condition
      #     statement
      #   end
      #
      # case
      # @example
      #   # bad
      #   case var
      #   when condition
      #     statement
      #   end
      #
      # @example
      #   # good
      #   if condition
      #     statement
      #   else
      #   # the content of the else branch will be determined by Style/EmptyElse
      #   end
      class MissingElse < Cop
        include OnNormalIfUnless
        include ConfigurableEnforcedStyle

        MSG = '`%s` condition requires an `else`-clause.'.freeze
        MSG_NIL = '`%s` condition requires an `else`-clause with ' \
                  '`nil` in it.'.freeze
        MSG_EMPTY = '`%s` condition requires an empty `else`-clause.'.freeze

        def on_normal_if_unless(node)
          unless_else_cop = config.for_cop('Style/UnlessElse')
          unless_else_enabled = unless_else_cop['Enabled'] if unless_else_cop

          return if unless_else_enabled && node.unless?

          check(node, if_else_clause(node)) unless style == :case
        end

        def on_case(node)
          check(node, case_else_clause(node)) unless style == :if
        end

        private

        def check(node, _else_clause)
          return if node.loc.else
          empty_else = config.for_cop('Style/EmptyElse')

          if empty_else && empty_else['Enabled']
            case empty_else['EnforcedStyle']
            when 'empty'
              add_offense(node, :expression, format(MSG_NIL, node.type))
            when 'nil'
              add_offense(node, :expression, format(MSG_EMPTY, node.type))
            end
          end

          add_offense(node, :expression, format(MSG, node.type))
        end
      end
    end
  end
end
