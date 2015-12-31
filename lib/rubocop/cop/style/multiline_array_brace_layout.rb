# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks that the closing brace in an array literal is
      # symmetrical with respect to the opening brace and the array
      # elements.
      #
      # If an array's opening brace is on the same line as the first element
      # of the array, then the closing brace should be on the same line as
      # the last element of the array.
      #
      # If an array's opening brace is on a separate line from the first
      # element of the array, then the closing brace should be on the line
      # after the last element of the array.
      #
      # @example
      #
      #     # bad
      #     [ :a,
      #       :b
      #     ]
      #
      #     # bad
      #     [
      #       :a,
      #       :b ]
      #
      #     # good
      #     [ :a,
      #       :b ]
      #
      #     #good
      #     [
      #       :a,
      #       :b
      #     ]
      class MultilineArrayBraceLayout < Cop
        SAME_LINE_MESSAGE = 'Closing array brace must be on the same line as ' \
          'the last array element when opening brace is on the same line as ' \
          'the first array element.'

        NEW_LINE_MESSAGE = 'Closing array brace must be on the line after ' \
          'the last array element when opening brace is on a separate line ' \
          'from the first array element.'

        def on_array(node)
          return unless node.loc.begin # Ignore implicit arrays.
          return if node.children.empty? # Ignore empty arrays.

          if opening_brace_on_same_line?(node)
            return if closing_brace_on_same_line?(node)

            add_offense(node, :expression, SAME_LINE_MESSAGE)
          else
            return unless closing_brace_on_same_line?(node)

            add_offense(node, :expression, NEW_LINE_MESSAGE)
          end
        end

        def autocorrect(node)
          if closing_brace_on_same_line?(node)
            lambda do |corrector|
              corrector.insert_before(node.loc.end, "\n".freeze)
            end
          else
            range = Parser::Source::Range.new(
              node.source_range.source_buffer,
              node.children.last.source_range.end_pos,
              node.loc.end.begin_pos)

            ->(corrector) { corrector.remove(range) }
          end
        end

        private

        # This method depends on the fact that we have guarded
        # against implicit and empty arrays.
        def opening_brace_on_same_line?(node)
          node.loc.begin.line == node.children.first.loc.first_line
        end

        # This method depends on the fact that we have guarded
        # against implicit and empty arrays.
        def closing_brace_on_same_line?(node)
          node.loc.end.line == node.children.last.loc.last_line
        end
      end
    end
  end
end
