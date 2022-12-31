# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Forbids Yoda expressions, i.e. binary operations (using `*`, `+`, `&`, `|`,
      # and `^` operators) where the order of expression is reversed, eg. `1 + x`.
      # This cop complements `Style/YodaCondition` cop, which has a similar purpose.
      #
      # @safety
      #   This cop is unsafe because binary operators can be defined
      #   differently on different classes, and are not guaranteed to
      #   have the same result if reversed.
      #
      # @example SupportedOperators: ['*', '+', '&'']
      #   # bad
      #   1 + x
      #   10 * y
      #   1 & z
      #
      #   # good
      #   60 * 24
      #   x + 1
      #   y * 10
      #   z & 1
      #
      #   # good
      #   1 | x
      #
      class YodaExpression < Base
        extend AutoCorrector

        MSG = 'Non-literal operand (`%<source>s`) should be first.'

        RESTRICT_ON_SEND = %i[* + & | ^].freeze

        def on_new_investigation
          @offended_nodes = nil
        end

        def on_send(node)
          return unless supported_operators.include?(node.method_name.to_s)

          lhs = node.receiver
          rhs = node.first_argument
          return if !lhs.numeric_type? || rhs.numeric_type?

          return if offended_ancestor?(node)

          message = format(MSG, source: rhs.source)
          add_offense(node, message: message) do |corrector|
            corrector.swap(lhs, rhs)
          end

          offended_nodes.add(node)
        end

        private

        def supported_operators
          Array(cop_config['SupportedOperators'])
        end

        def offended_ancestor?(node)
          node.each_ancestor(:send).any? { |ancestor| @offended_nodes&.include?(ancestor) }
        end

        def offended_nodes
          @offended_nodes ||= Set.new.compare_by_identity
        end
      end
    end
  end
end
