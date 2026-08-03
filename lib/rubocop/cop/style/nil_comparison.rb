# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for comparison of something with nil using `==` and
      # `nil?`. Enforcing a consistent style (either the `nil?`
      # predicate or `==` comparison) improves readability.
      #
      # @example EnforcedStyle: predicate (default)
      #
      #   # bad
      #   if x == nil
      #   end
      #
      #   # good
      #   if x.nil?
      #   end
      #
      # @example EnforcedStyle: comparison
      #
      #   # bad
      #   if x.nil?
      #   end
      #
      #   # good
      #   if x == nil
      #   end
      #
      class NilComparison < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        PREDICATE_MSG = 'Prefer the use of the `nil?` predicate.'
        EXPLICIT_MSG = 'Prefer the use of the `==` comparison.'

        RESTRICT_ON_SEND = %i[== === nil?].freeze

        # @!method nil_comparison?(node)
        def_node_matcher :nil_comparison?, '(send _ {:== :===} nil)'

        # @!method nil_check?(node)
        def_node_matcher :nil_check?, '(send _ :nil?)'

        def on_send(node)
          return unless node.receiver

          style_check?(node) do
            add_offense(node.loc.selector) do |corrector|
              if prefer_comparison?
                autocorrect_to_comparison(corrector, node)
              else
                autocorrect_to_predicate(corrector, node)
              end
            end
          end
        end

        private

        def autocorrect_to_comparison(corrector, node)
          range = node.loc.dot.join(node.loc.selector.end)
          corrector.replace(range, ' == nil')
          # The new `== nil` binds looser than an enclosing operator (e.g. `<<`,
          # `!`), so wrap it to keep the original precedence.
          corrector.wrap(node, '(', ')') if operator_expression?(node.parent)
        end

        def autocorrect_to_predicate(corrector, node)
          receiver = node.receiver
          if operator_expression?(receiver)
            # A looser-binding receiver (e.g. `!x`, `a + b`) must be parenthesized
            # so the appended `.nil?` applies to the whole expression.
            corrector.replace(node, "(#{receiver.source}).nil?")
          else
            range = receiver.source_range.end.join(node.source_range.end)
            corrector.replace(range, '.nil?')
          end
        end

        def operator_expression?(node)
          return false unless node

          operator_send?(node) ||
            node.operator_keyword? ||
            (node.if_type? && node.ternary?) ||
            node.type?(:range, :iflipflop, :eflipflop) ||
            node.assignment?
        end

        def operator_send?(node)
          node.send_type? && node.operator_method? && !node.method?(:[]) && !node.method?(:[]=)
        end

        def message(_node)
          prefer_comparison? ? EXPLICIT_MSG : PREDICATE_MSG
        end

        def style_check?(node, &block)
          if prefer_comparison?
            nil_check?(node, &block)
          else
            nil_comparison?(node, &block)
          end
        end

        def prefer_comparison?
          style == :comparison
        end
      end
    end
  end
end
