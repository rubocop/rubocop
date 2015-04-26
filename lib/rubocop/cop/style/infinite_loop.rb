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

        TRUTHY_LITERALS = [:str, :dstr, :int, :float, :array,
                           :hash, :regexp, :true]

        FALSEY_LITERALS = [:nil, :false]

        def on_while(node)
          condition, = *node

          return unless TRUTHY_LITERALS.include?(condition.type)

          add_offense(node, :keyword)
        end

        def on_until(node)
          condition, = *node

          return unless FALSEY_LITERALS.include?(condition.type)

          add_offense(node, :keyword)
        end

        def autocorrect(node)
          condition_node, = *node
          start_range = node.loc.keyword.begin
          end_range = if node.loc.begin
                        node.loc.begin.end
                      else
                        condition_node.loc.expression.end
                      end
          lambda do |corrector|
            corrector.replace(start_range.join(end_range), 'loop do')
          end
        end
      end
    end
  end
end
