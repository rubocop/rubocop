# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Detects the use of C-style increment (++) and decrement (--) operators,
      # which are not increment or decrement operators in Ruby.
      # In Ruby, ++ and -- are interpreted as double unary operators (+ or - applied twice),
      # which can unexpectedly alter the sign of a value rather than changing its magnitude.
      # Use += 1 for increments and -= 1 for decrements instead.
      #
      # @example
      #
      #   # bad
      #   ++counter
      #   --counter
      #
      #   # good
      #   counter += 1
      #   counter -= 1
      class CStyleIncrementDecrement < Base
        extend AutoCorrector

        MESSAGE_BY_OPERATOR = {
          :+@ => 'C-style increment operators are not supported in Ruby. Use `+= 1` instead.',
          :-@ => 'C-style decrement operators are not supported in Ruby. Use `-= 1` instead.'
        }.freeze

        # @!method c_style_increment?(node)
        def_node_matcher :c_style_increment?, <<~PATTERN
          (send
            (send
              (send _ _) :+@) :+@)
        PATTERN

        # @!method c_style_decrement?(node)
        def_node_matcher :c_style_decrement?, <<~PATTERN
          (send
            (send
              (send _ _) :-@) :-@)
        PATTERN

        def on_send(node)
          return unless c_style_increment?(node) || c_style_decrement?(node)

          add_offense(node, message: MESSAGE_BY_OPERATOR[node.method_name]) do |corrector|
            operator = node.method_name.to_s.sub('@', '')
            variable = node.receiver.receiver.source

            replacement = "#{variable} #{operator}= 1"

            corrector.replace(node, replacement)
          end
        end
      end
    end
  end
end
