# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that multiline memoizations are wrapped in a `begin`
      # and `end` block.
      #
      # @example
      #
      #   @bad
      #   foo ||= (
      #     bar
      #     baz
      #   )
      #
      #   @good
      #   foo ||= begin
      #     bar
      #     baz
      #   end
      class MultilineMemoization < Cop
        MSG = 'Wrap multiline memoization blocks in `begin` and `end`.'.freeze

        def on_or_asgn(node)
          _lhs, rhs = *node

          return unless rhs.multiline? && rhs.begin_type?

          add_offense(rhs, node.source_range, MSG)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.loc.begin, 'begin')
            corrector.replace(node.loc.end, 'end')
          end
        end
      end
    end
  end
end
