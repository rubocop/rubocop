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
      end
    end
  end
end
