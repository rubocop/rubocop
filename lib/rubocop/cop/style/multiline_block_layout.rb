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
        MSG = 'Block body expression is on the same line as the block start.'

        def on_block(node)
          end_loc = node.loc.end
          do_loc = node.loc.begin # Actually it's either do or {.
          return if do_loc.line == end_loc.line # One-liner, no newline needed.

          # A block node has three children: the block start,
          # the arguments, and the expression. We care if the block start
          # and the expression start on the same line.
          last_expression = node.children.last
          return unless last_expression
          expression_loc = last_expression.loc
          return unless do_loc.line == expression_loc.line

          expression = last_expression.loc.expression
          range = Parser::Source::Range.new(expression.source_buffer,
                                            expression.begin_pos,
                                            expression.end_pos)

          add_offense(node, range)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            _method, _args, block_body = *node
            first_node = if block_body.type == :begin
                           block_body.children.first
                         else
                           block_body
                         end

            block_start_col = node.loc.expression.column

            corrector.insert_before(first_node.loc.expression,
                                    "\n  #{' ' * block_start_col}")
          end
        end
      end
    end
  end
end
