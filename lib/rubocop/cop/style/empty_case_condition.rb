# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for case statements with an empty condition.
      #
      # @example
      #
      #   # bad:
      #   case
      #   when x == 0
      #     puts 'x is 0'
      #   when y == 0
      #     puts 'y is 0'
      #   else
      #     puts 'neither is 0'
      #   end
      #
      #   # good:
      #   if x == 0
      #     puts 'x is 0'
      #   elsif y == 0
      #     puts 'y is 0'
      #   else
      #     puts 'neither is 0'
      #   end
      #
      #   # good: (the case condition node is not empty)
      #   case n
      #   when 0
      #     puts 'zero'
      #   when 1
      #     puts 'one'
      #   else
      #     puts 'more'
      #   end
      class EmptyCaseCondition < Cop
        MSG = 'Do not use empty `case` condition, instead use an `if` '\
              'expression.'.freeze

        def on_case(case_node)
          condition_node = case_node.children.first

          add_offense(case_node, :keyword, MSG) if condition_node.nil?
        end

        private

        def autocorrect(case_node)
          lambda do |corrector|
            _cond_node, *when_nodes, _else_node = *case_node

            correct_case_whens(corrector, case_node, when_nodes)

            correct_multiple_alternative_whens(corrector, when_nodes)
          end
        end

        def correct_case_whens(corrector, case_node, when_nodes)
          case_to_first_when =
            case_node.loc.keyword.join(when_nodes.first.loc.keyword)

          corrector.replace(case_to_first_when, 'if')

          when_nodes.drop(1).each do |when_node|
            corrector.replace(when_node.loc.keyword, 'elsif')
          end
        end

        # Since an if condition containing commas is not syntactically valid, we
        # correct `when x, y` to `if x || y`.
        def correct_multiple_alternative_whens(corrector, when_nodes)
          when_nodes.each do |when_node|
            # In `when a; r` we have two children: [a, r].
            # In `when a, b, c; r` we have 4.
            # In `when a, b then r` we have 3.
            *children, _ = when_node.children

            next unless children.size > 1

            first = children.first
            last = children.last
            range = range_between(first.loc.expression.begin_pos,
                                  last.loc.expression.end_pos)

            corrector.replace(range, children.map(&:source).join(' || '))
          end
        end
      end
    end
  end
end
