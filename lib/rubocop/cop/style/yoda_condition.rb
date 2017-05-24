# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for Yoda conditions, i.e. comparison operations where
      # readability is reduced because the operands are not ordered the same
      # way as they would be ordered in spoken English.
      #
      # @example
      #
      #   # bad
      #   99 == foo
      #   "bar" == foo
      #   42 >= foo
      #
      # @example
      #
      #   # good
      #   foo == 99
      #   foo == "bar"
      #   for <= 42
      class YodaCondition < Cop
        MSG = 'Reverse the order of the operands `%s`.'.freeze
        WHITELIST_TYPES = %i[lvar ivar cvar gvar csend send const begin].freeze
        REVERSE_COMPARISON = {
          '<' => '>',
          '<=' => '>=',
          '>' => '<',
          '>=' => '<='
        }.freeze

        def on_send(node)
          return unless yoda_condition?(node)

          register_offense(node)
        end

        private

        def yoda_condition?(node)
          return false unless comparison_operator?(node)

          !WHITELIST_TYPES.include?(node.receiver.type)
        end

        def comparison_operator?(node)
          RuboCop::AST::Node::COMPARISON_OPERATORS.include?(node.method_name)
        end

        def register_offense(node)
          add_offense(node, :expression, format(MSG, node.source))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(actual_code_range(node), corrected_code(node))
          end
        end

        def corrected_code(node)
          first, operator, last = node.children
          "#{last.source} #{reverse_comparison(operator)} #{first.source}"
        end

        def actual_code_range(node)
          range_between(
            node.loc.expression.begin_pos, node.loc.expression.end_pos
          )
        end

        def reverse_comparison(operator)
          REVERSE_COMPARISON.fetch(operator.to_s, operator)
        end
      end
    end
  end
end
