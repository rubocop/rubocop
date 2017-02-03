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
              add_offense(node, :expression, format(MSG_NIL, node.type))
            elsif empty_else_style == :nil
              add_offense(node, :expression, format(MSG_EMPTY, node.type))
            end
          end

          add_offense(node, :expression, format(MSG, node.type))
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
