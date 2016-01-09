# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for places where Fixnum#even? or Fixnum#odd?
      # should have been used.
      #
      # @example
      #
      #   # bad
      #   if x % 2 == 0
      #
      #   # good
      #   if x.even?
      class EvenOdd < Cop
        MSG = 'Replace with `Fixnum#%s?`.'.freeze

        ZERO = s(:int, 0)
        ONE = s(:int, 1)
        TWO = s(:int, 2)

        def on_send(node)
          offense = offense_type(node)
          add_offense(node, :expression, format(MSG, offense)) if offense
        end

        def autocorrect(node)
          correction = "#{base_number(node)}.#{offense_type(node)}?"
          ->(corrector) { corrector.replace(node.source_range, correction) }
        end

        private

        def base_number(node)
          receiver, = *node
          node = expression(receiver)
          node.children[0].source
        end

        def offense_type(node)
          receiver, method, args = *node

          return unless [:==, :!=].include?(method)
          return unless div_by_2?(receiver)

          if args == ZERO
            method == :== ? :even : :odd
          elsif args == ONE
            method == :== ? :odd : :even
          end
        end

        def div_by_2?(node)
          node = expression(node)

          _receiver, method, args = *node

          method == :% && args == TWO
        end

        def expression(node)
          return unless node

          # check for scenarios like (x % 2) == 0
          if node.type == :begin && node.children.size == 1
            node = node.children.first
          end

          return unless node.type == :send
          node
        end
      end
    end
  end
end
