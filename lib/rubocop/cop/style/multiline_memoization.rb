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
          b = node.loc.begin
          e = node.loc.end

          lambda do |corrector|
            if style == :keyword
              replacement = if newline_after?(node, b.end_pos)
                              'begin'
                            else
                              "begin\n" + (' ' * b.begin_pos)
                            end
              corrector.replace(b, replacement)

              replacement = if newline_before?(node)
                              "\n" + (' ' * b.begin_pos) + 'end'
                            else
                              'end'
                            end

              corrector.replace(e, replacement)
            else
              corrector.replace(b, '(')
              corrector.replace(e, ')')
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

        def newline_after?(node, pos)
          node.source_range.source_buffer.source[pos] == "\n"
        end

        def newline_before?(node)
          node.source_range.source_buffer.source_line(node.loc.end.line) =~
           /[^\s\)]/
        end
      end
    end
  end
end
