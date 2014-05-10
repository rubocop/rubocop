# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks whether the multiline do end blocks have a newline
      # after the start of the block.
      #
      # @example
      #   # bad
      #   blah do |i| foo(i)
      #     bar(i)
      #   end
      #
      #   # good
      #   blah do |i|
      #     foo(i)
      #     bar(i)
      #   end
      #
      #   # bad
      #   blah { |i| foo(i)
      #     bar(i)
      #   }
      #
      #   # good
      #   blah { |i|
      #     foo(i)
      #     bar(i)
      #   }
      class MultilineBlockLayout < Cop
        MSG = 'expression at %d, %d is on the same line as the block start'

        def on_block(node)
          end_loc = node.loc.end
          do_loc = node.loc.begin # Actually it's either do or {.
          return if do_loc.line == end_loc.line # One-liner, no newline needed.

          # A block node has three children: the block start,
          # the arguments, and the expression. We care if the block start
          # and the expression start on the same line.
          expression_loc = node.children.last.loc
          return unless do_loc.line == expression_loc.line

          error = format(MSG, expression_loc.line, expression_loc.column)
          add_offense(node, expression_loc, error)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            expression = node.children.last

            start_col = node.loc.expression.column
            expression_start = expression.loc.column

            source = node.loc.expression.source_buffer
            range = Parser::Source::Range.new(source,
                                              expression_start - 1,
                                              expression_start)

            corrector.insert_after(range, "\n  #{' ' * start_col}")
          end
        end
      end
    end
  end
end
