# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks expressions wrapping styles for multiline memoization.
      #
      # @example
      #
      #   # EnforcedStyle: keyword (default)
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
      #
      # @example
      #
      #   # EnforcedStyle: braces
      #
      #   @bad
      #   foo ||= begin
      #     bar
      #     baz
      #   end
      #
      #   @good
      #   foo ||= (
      #     bar
      #     baz
      #   )
      class MultilineMemoization < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Wrap multiline memoization blocks in `begin` and `end`.'.freeze

        def on_or_asgn(node)
          _lhs, rhs = *node

          return unless bad_rhs?(rhs)

          add_offense(rhs, node.source_range, MSG)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            if style == :keyword
              corrector.replace(node.loc.begin, 'begin')
              corrector.replace(node.loc.end, 'end')
            else
              corrector.replace(node.loc.begin, '(')
              corrector.replace(node.loc.end, ')')
            end
          end
        end

        def bad_rhs?(rhs)
          return false unless rhs.multiline?
          if style == :keyword
            rhs.begin_type?
          else
            rhs.kwbegin_type?
          end
        end
      end
    end
  end
end
