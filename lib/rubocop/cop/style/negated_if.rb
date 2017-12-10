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
      # @example EnforcedStyle: both (default)
      #   # enforces `unless` for `prefix` and `postfix` conditionals
      #
      #   # bad
      #
      #   if !foo
      #     bar
      #   end
      #
      #   # good
      #
      #   unless foo
      #     bar
      #   end
      #
      #   # bad
      #
      #   bar if !foo
      #
      #   # good
      #
      #   bar unless foo
      #
      # @example EnforcedStyle: prefix
      #   # enforces `unless` for just `prefix` conditionals
      #
      #   # bad
      #
      #   if !foo
      #     bar
      #   end
      #
      #   # good
      #
      #   unless foo
      #     bar
      #   end
      #
      #   # good
      #
      #   bar if !foo
      #
      # @example EnforcedStyle: postfix
      #   # enforces `unless` for just `postfix` conditionals
      #
      #   # bad
      #
      #   bar if !foo
      #
      #   # good
      #
      #   bar unless foo
      #
      #   # good
      #
      #   if !foo
      #     bar
      #   end
      class NegatedIf < Cop
        include ConfigurableEnforcedStyle
        include NegativeConditional

        def on_if(node)
          return if node.elsif? || node.ternary?
          return if correct_style?(node)

          check_negative_conditional(node)
        end

        def autocorrect(node)
          negative_conditional_corrector(node)
        end

        private

        def message(node)
          format(MSG, inverse: node.inverse_keyword, current: node.keyword)
        end

        def correct_style?(node)
          style == :prefix && node.modifier_form? ||
            style == :postfix && !node.modifier_form?
        end
      end
    end
  end
end
