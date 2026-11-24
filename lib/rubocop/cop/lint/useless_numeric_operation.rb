# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Certain numeric operations have no impact, being:
      # Adding or subtracting 0, multiplying or dividing by 1 or raising to the power of 1.
      # These are probably leftover from debugging, or are mistakes.
      #
      # @example
      #
      #   # bad
      #   x + 0
      #   x - 0
      #   x * 1
      #   x / 1
      #   x ** 1
      #
      #   # good
      #   x
      #
      #   # bad
      #   x += 0
      #   x -= 0
      #   x *= 1
      #   x /= 1
      #   x **= 1
      #
      #   # good
      #   x = x
      #
      class UselessNumericOperation < Base
        extend AutoCorrector

        MSG = 'Do not apply inconsequential numeric operations to variables.'
        RESTRICT_ON_SEND = %i[+ - * / **].freeze

        # @!method useless_operation?(node)
        def_node_matcher :useless_operation?, <<~PATTERN
          (call ${lvar ivar cvar gvar const (send nil? _)} $_ (int $_))
        PATTERN

        # @!method useless_abbreviated_assignment?(node)
        def_node_matcher :useless_abbreviated_assignment?, <<~PATTERN
          (op-asgn ${lvasgn ivasgn cvasgn gvasgn casgn} $_ (int $_))
        PATTERN

        def on_send(node)
          return unless (receiver, operation, number = useless_operation?(node))
          return unless useless?(operation, number)

          register_offense(node, receiver.source)
        end
        alias on_csend on_send

        def on_op_asgn(node)
          return unless (variable, operation, number = useless_abbreviated_assignment?(node))
          return unless useless?(operation, number)

          register_offense(node, "#{variable.source} = #{variable.source}")
        end

        private

        def useless?(operation, number)
          if number.zero?
            true if %i[+ -].include?(operation)
          elsif number == 1
            true if %i[* / **].include?(operation)
          end
        end

        def register_offense(node, replacement)
          add_offense(node) do |corrector|
            next if unsafe_replacement?(node)

            corrector.replace(node, replacement)
          end
        end

        def unsafe_replacement?(node)
          return false if node.single_line?

          processed_source.tokens_within(node).any? do |token|
            token.comment? || token.type == :tSTRING_END
          end
        end
      end
    end
  end
end
