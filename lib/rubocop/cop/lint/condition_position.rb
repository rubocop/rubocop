# encoding: utf-8

module Rubocop
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
          condition, = *node

          if on_different_line?(node.loc.keyword.line,
                                condition.loc.expression.line)
            add_offence(condition, :expression,
                        message(node.loc.keyword.source))
          end
        end

        def message(keyword)
          "Place the condition on the same line as #{keyword}."
        end

        def on_different_line?(keyword_line, cond_line)
          keyword_line != cond_line
        end
      end
    end
  end
end
