# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for conditions that are not on the same line as
      # if/while/until.
      #
      # @example
      #
      #   # bad
      #
      #   if
      #     some_condition
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   if some_condition
      #     do_something
      #   end
      class ConditionPosition < Cop
        MSG = 'Place the condition on the same line as `%<keyword>s`.'.freeze

        def on_if(node)
          return if node.ternary?

          check(node)
        end

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        private

        def check(node)
          return if node.modifier_form? || node.single_line_condition?

          add_offense(node.condition)
        end

        def message(node)
          format(MSG, keyword: node.parent.keyword)
        end
      end
    end
  end
end
