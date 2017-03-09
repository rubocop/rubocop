# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of if with a negated condition. Only ifs
      # without else are considered. There are three different styles:
      #
      # @example
      #
      # both - enforces `unless` for `prefix` and `postfix` conditionals
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
      # prefix - enforces `unless` for just `prefix` conditionals
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
      # postfix - enforces `unless` for just `postfix` conditionals
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
          return if style == :prefix && node.modifier_form?
          return if style == :postfix && !node.modifier_form?

          check_negative_conditional(node)
        end

        def message(node)
          format(MSG, node.inverse_keyword, node.keyword)
        end

        private

        def autocorrect(node)
          negative_conditional_corrector(node)
        end
      end
    end
  end
end
