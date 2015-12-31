# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Use `Kernel#loop` for infinite loops.
      #
      # @example
      #   # bad
      #   while true
      #     work
      #   end
      #
      #   # good
      #   loop do
      #     work
      #   end
      class InfiniteLoop < Cop
        MSG = 'Use `Kernel#loop` for infinite loops.'

        def on_while(node)
          condition, = *node

          return unless condition.truthy_literal?

          add_offense(node, :keyword)
        end

        def on_until(node)
          condition, = *node

          return unless condition.falsey_literal?

          add_offense(node, :keyword)
        end

        def autocorrect(node)
          condition_node, = *node
          start_range = node.loc.keyword.begin
          end_range = if node.loc.begin
                        node.loc.begin.end
                      else
                        condition_node.source_range.end
                      end
          lambda do |corrector|
            corrector.replace(start_range.join(end_range), 'loop do')
          end
        end
      end
    end
  end
end
