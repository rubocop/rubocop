# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
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
          return if !(node.if_type? && node.elsif?) && node.loc.end.nil?

          condition, = *node
          return if node.loc.keyword.line == condition.source_range.line

          add_offense(condition, :expression, message(node.loc.keyword.source))
        end

        def message(keyword)
          "Place the condition on the same line as `#{keyword}`."
        end
      end
    end
  end
end
