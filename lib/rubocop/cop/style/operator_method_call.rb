# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant dot before operator method call.
      # The target operator methods are `|`, `^`, `&`, `<=>`, `==`, `===`, `=~`, `>`, `>=`, `<`,
      # `<=`, `<<`, `>>`, `+`, `-`, `*`, `/`, `%`, `**`, `~`, `!`, `!=`, and `!~`.
      #
      # @example
      #
      #   # bad
      #   foo.+ bar
      #   foo.& bar
      #
      #   # good
      #   foo + bar
      #   foo & bar
      #
      class OperatorMethodCall < Base
        extend AutoCorrector

        MSG = 'Redundant dot detected.'
        RESTRICT_ON_SEND = %i[| ^ & <=> == === =~ > >= < <= << >> + - * / % ** ~ ! != !~].freeze

        def on_send(node)
          return unless (dot = node.loc.dot)
          return if node.receiver.const_type?

          _lhs, _op, rhs = *node
          return if rhs.nil? || rhs.children.first

          add_offense(dot) do |corrector|
            wrap_in_parentheses_if_chained(corrector, node)
            corrector.replace(dot, ' ')
          end
        end

        private

        def wrap_in_parentheses_if_chained(corrector, node)
          return unless node.parent&.call_type?

          operator = node.loc.selector

          ParenthesesCorrector.correct(corrector, node)
          corrector.insert_after(operator, ' ')
          corrector.wrap(node, '(', ')')
        end
      end
    end
  end
end
