# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces the use of `Array#push(item)` instead of `Array#concat([item])`
      # to avoid redundant array literals.
      #
      # @safety
      #   This cop is unsafe, as it can produce false positives if the receiver
      #   is not an `Array` object.
      #
      # @example
      #
      #   # bad
      #   list.concat([foo])
      #   list.concat([bar, baz])
      #   list.concat([qux, quux], [corge])
      #
      #   # good
      #   list.push(foo)
      #   list.push(bar, baz)
      #   list.push(qux, quux, corge)
      #
      class ConcatArrayLiterals < Base
        extend AutoCorrector

        MSG = 'Use `%{prefer}` instead of `%{current}`.'
        MSG_FOR_PERCENT_LITERALS =
          'Use `push` with elements as arguments without array brackets instead of `%{current}`.'
        RESTRICT_ON_SEND = %i[concat].freeze

        # rubocop:disable Metrics
        def on_send(node)
          return if node.arguments.empty?
          return unless node.arguments.all?(&:array_type?)

          offense = offense_range(node)
          current = offense.source

          if node.arguments.any?(&:percent_literal?)
            if percent_literals_includes_only_basic_literals?(node)
              prefer = preferred_method(node)
              message = format(MSG, prefer: prefer, current: current)
            else
              message = format(MSG_FOR_PERCENT_LITERALS, current: current)
            end
          else
            prefer = preferred_method(node)
            message = format(MSG, prefer: prefer, current: current)
          end

          add_offense(offense, message: message) do |corrector|
            corrector.replace(offense, prefer)
          end
        end
        # rubocop:enable Metrics

        private

        def offense_range(node)
          node.loc.selector.join(node.source_range.end)
        end

        def preferred_method(node)
          new_arguments =
            node.arguments.map do |arg|
              if arg.percent_literal?
                arg.children.map(&:value).map(&:inspect)
              else
                arg.children.map(&:source)
              end
            end.join(', ')

          "push(#{new_arguments})"
        end

        def percent_literals_includes_only_basic_literals?(node)
          node.arguments.select(&:percent_literal?).all? do |arg|
            arg.children.all? { |child| child.str_type? || child.sym_type? }
          end
        end
      end
    end
  end
end
