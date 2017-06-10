# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of if with a negated condition. Only ifs
      # without else are considered. There are three different styles:
      #
      #   - both
      #   - prefix
      #   - postfix
      #
      # @example
      #
      #   # EnforcedStyle: both
      #   # enforces `unless` for `prefix` and `postfix` conditionals
      #
      #   # good
      #
      #   unless foo
      #     bar
      #   end
      #
      #   # bad
      #
      #   if !foo
      #     bar
      #   end
      #
      #   # good
      #
      #   bar unless foo
      #
      #   # bad
      #
      #   bar if !foo
      #
      # @example
      #
      #   # EnforcedStyle: prefix
      #   # enforces `unless` for just `prefix` conditionals
      #
      #   # good
      #
      #   unless foo
      #     bar
      #   end
      #
      #   # bad
      #
      #   if !foo
      #     bar
      #   end
      #
      #   # good
      #
      #   bar if !foo
      #
      # @example
      #
      #   # EnforcedStyle: postfix
      #   # enforces `unless` for just `postfix` conditionals
      #
      #   # good
      #
      #   bar unless foo
      #
      #   # bad
      #
      #   bar if !foo
      #
      #   # good
      #
      #   if !foo
      #     bar
      #   end
      class NegatedIf < Cop
        include ConfigurableEnforcedStyle
        include NegativeConditional

        MSG = 'Favor `%s` over `%s` for negative conditions.'.freeze

        def on_if(node)
          return if node.elsif? || node.ternary?
          return if correct_style?(node)

          check_negative_conditional(node)
        end

        private

        def message(node)
          format(MSG, node.inverse_keyword, node.keyword)
        end

        def autocorrect(node)
          negative_conditional_corrector(node)
        end

        def correct_style?(node)
          style == :prefix && node.modifier_form? ||
            style == :postfix && !node.modifier_form?
        end
      end
    end
  end
end
