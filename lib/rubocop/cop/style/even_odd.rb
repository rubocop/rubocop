# encoding: utf-8
# frozen_string_literal: true

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

        EQUALITY_OPERATORS = [:==, :!=].freeze

        def on_send(node)
          offense_type(node) do |replacement_method|
            add_offense(node, :expression, format(MSG, replacement_method))
          end
        end

        def autocorrect(node)
          offense_type(node) do |replacement_method|
            correction = "#{base_number(node)}.#{replacement_method}?"
            ->(corrector) { corrector.replace(node.source_range, correction) }
          end
        end

        private

        def base_number(node)
          receiver, = *node
          node = expression(receiver)
          node.children.first.source
        end

        def offense_type(node)
          receiver, method, args = *node

          return unless equality_operator?(method)
          return unless div_by_2?(receiver)

          replacement_method(args, method) { |odd_or_even| yield odd_or_even }
        end

        def equality_operator?(method_name)
          EQUALITY_OPERATORS.include?(method_name)
        end

        def div_by_2?(node)
          node = expression(node)

          _receiver, method, args = *node

          method == :% && args == TWO
        end

        def replacement_method(args, method)
          if args == ZERO
            yield method == :== ? :even : :odd
          elsif args == ONE
            yield method == :== ? :odd : :even
          end
        end

        def expression(node)
          return unless node

          # check for scenarios like (x % 2) == 0
          node = node.children.first if node.begin_type? && node.children.one?

          return unless node.send_type?
          node
        end
      end
    end
  end
end
