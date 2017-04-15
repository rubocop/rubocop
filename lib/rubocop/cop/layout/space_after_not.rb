# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for space after `!`.
      #
      # @example
      #   # bad
      #   ! something
      #
      #   # good
      #   !something
      class SpaceAfterNot < Cop
        MSG = 'Do not leave space between `!` and its argument.'.freeze

        def on_send(node)
          return unless node.keyword_bang? && whitespace_after_operator?(node)

          add_offense(node, :expression)
        end

        def whitespace_after_operator?(node)
          node.receiver.loc.column - node.loc.column > 1
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(
              range_between(node.loc.selector.end_pos,
                            node.receiver.source_range.begin_pos)
            )
          end
        end
      end
    end
  end
end
