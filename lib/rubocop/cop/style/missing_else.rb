# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `if` expressions that do not have an `else` branch.
      #
      # Supported styles are: if, case, both.
      #
      # @example EnforcedStyle: if
      #   # warn when an `if` expression is missing an `else` branch.
      #
      #   # bad
      #   if condition
      #     statement
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   else
      #     # the content of `else` branch will be determined by Style/EmptyElse
      #   end
      #
      #   # good
      #   case var
      #   when condition
      #     statement
      #   end
      #
      #   # good
      #   case var
      #   when condition
      #     statement
      #   else
      #     # the content of `else` branch will be determined by Style/EmptyElse
      #   end
      #
      # @example EnforcedStyle: case
      #   # warn when a `case` expression is missing an `else` branch.
      #
      #   # bad
      #   case var
      #   when condition
      #     statement
      #   end
      #
      #   # good
      #   case var
      #   when condition
      #     statement
      #   else
      #     # the content of `else` branch will be determined by Style/EmptyElse
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   else
      #     # the content of `else` branch will be determined by Style/EmptyElse
      #   end
      #
      # @example EnforcedStyle: both (default)
      #   # warn when an `if` or `case` expression is missing an `else` branch.
      #
      #   # bad
      #   if condition
      #     statement
      #   end
      #
      #   # bad
      #   case var
      #   when condition
      #     statement
      #   end
      #
      #   # good
      #   if condition
      #     statement
      #   else
      #     # the content of `else` branch will be determined by Style/EmptyElse
      #   end
      #
      #   # good
      #   case var
      #   when condition
      #     statement
      #   else
      #     # the content of `else` branch will be determined by Style/EmptyElse
      #   end
      class MissingElse < Cop
        include OnNormalIfUnless
        include ConfigurableEnforcedStyle

        MSG = '`%<type>s` condition requires an `else`-clause.'
        MSG_NIL = '`%<type>s` condition requires an `else`-clause with ' \
                  '`nil` in it.'
        MSG_EMPTY = '`%<type>s` condition requires an empty ' \
                    '`else`-clause.'

        def on_normal_if_unless(node)
          return if case_style?
          return if unless_else_cop_enabled? && node.unless?

          check(node)
        end

        def on_case(node)
          return if if_style?

          check(node)
        end

        private

        def check(node)
          return if node.else?

          if empty_else_cop_enabled?
            if empty_else_style == :empty
              add_offense(node)
            elsif empty_else_style == :nil
              add_offense(node)
            end
          end

          add_offense(node)
        end

        def message(node)
          template = case empty_else_style
                     when :empty
                       MSG_NIL
                     when :nil
                       MSG_EMPTY
                     else
                       MSG
                     end

          format(template, type: node.type)
        end

        def if_style?
          style == :if
        end

        def case_style?
          style == :case
        end

        def unless_else_cop_enabled?
          unless_else_config.fetch('Enabled')
        end

        def unless_else_config
          config.for_cop('Style/UnlessElse')
        end

        def empty_else_cop_enabled?
          empty_else_config.fetch('Enabled')
        end

        def empty_else_style
          return unless empty_else_config.key?('EnforcedStyle')

          empty_else_config['EnforcedStyle'].to_sym
        end

        def empty_else_config
          config.for_cop('Style/EmptyElse')
        end
      end
    end
  end
end
