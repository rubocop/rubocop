# encoding: utf-8

module Rubocop
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
        MSG_EVEN = 'Use Fixnum.even?'
        MSG_ODD = 'Use Fixnum.odd?'

        ZERO = s(:int, 0)
        ONE = s(:int, 1)
        TWO = s(:int, 2)

        def on_send(node)
          receiver, method, args = *node

          return unless method == :==
          return unless div_by_2?(receiver)

          if args == ZERO
            convention(node, :expression, MSG_EVEN)
          elsif args == ONE
            convention(node, :expression, MSG_ODD)
          end
        end

        private

        def div_by_2?(node)
          return unless node

          # check for scenarios like (x % 2) == 0
          if node.type == :begin && node.children.size == 1
            node = node.children.first
          end

          return unless node.type == :send

          _receiver, method, args = *node

          method == :% && args == TWO
        end
      end
    end
  end
end
