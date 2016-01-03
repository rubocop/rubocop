# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for conditions that are not on the same line as
      # if/while/until.
      #
      # @example
      #
      #   if
      #     some_condition
      #     do_something
      #   end
      class ConditionPosition < Cop
        def on_if(node)
          return if node.loc.respond_to?(:question)

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
          return if !node.loc.keyword.is?('elsif') && node.loc.end.nil?

          condition, = *node
          return unless on_different_line?(node.loc.keyword.line,
                                           condition.source_range.line)

          add_offense(condition, :expression, message(node.loc.keyword.source))
        end

        def message(keyword)
          "Place the condition on the same line as `#{keyword}`."
        end

        def on_different_line?(keyword_line, cond_line)
          keyword_line != cond_line
        end
      end
    end
  end
end
