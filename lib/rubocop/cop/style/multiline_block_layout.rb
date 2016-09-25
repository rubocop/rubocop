# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether the multiline do end blocks have a newline
      # after the start of the block. Additionally, it checks whether the block
      # arguments, if any, are on the same line as the start of the block.
      #
      # @example
      #   # bad
      #   blah do |i| foo(i)
      #     bar(i)
      #   end
      #
      #   # bad
      #   blah do
      #     |i| foo(i)
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
        MSG = 'Block body expression is on the same line as ' \
              'the block start.'.freeze
        ARG_MSG = 'Block argument expression is not on the same line as the ' \
                  'block start.'.freeze

        def on_block(node)
          return if oneliner?(node)

          # A block node has three children: the block start,
          # the arguments, and the expression. We care if the block start
          # with arguments and the expression start on the same line.
          _block_start, args, last_expression = node.children
          do_loc = node.loc.begin # Actually it's either do or {.

          if args_on_different_line?(do_loc.line, args)
            add_offense_for_expression(node, args, ARG_MSG)
          end

          return unless last_expression
          expression_loc = last_expression.loc
          return unless do_loc.line == expression_loc.line
          add_offense_for_expression(node, last_expression, MSG)
        end

        def oneliner?(node)
          node.loc.begin.line == node.loc.end.line
        end

        def args_on_different_line?(do_line, args)
          return false if args.children.empty?

          do_line != args.loc.last_line
        end

        def add_offense_for_expression(node, expr, msg)
          expression = expr.source_range
          range = range_between(expression.begin_pos, expression.end_pos)

          add_offense(node, range, msg)
        end

        def autocorrect(node)
          lambda do |corrector|
            _method, args, block_body = *node
            unless arguments_on_different_line?(node, args)
              autocorrect_arguments(corrector, node, args)
              expr_before_body = args.source_range.end
            end

            return unless block_body

            expr_before_body ||= node.loc.begin
            if expr_before_body.line == block_body.loc.line
              autocorrect_body(corrector, node, block_body)
            end
          end
        end

        def arguments_on_different_line?(node, args)
          args.children.empty? || args.loc.last_line == node.loc.line
        end

        def autocorrect_arguments(corrector, node, args)
          end_pos =
            range_with_surrounding_space(args.source_range, :right, false)
            .end_pos
          range = range_between(node.loc.begin.end.begin_pos, end_pos)
          corrector.replace(range, " |#{block_arg_string(args)}|")
        end

        def autocorrect_body(corrector, node, block_body)
          first_node = if block_body.begin_type?
                         block_body.children.first
                       else
                         block_body
                       end

          block_start_col = node.source_range.column

          corrector.insert_before(first_node.source_range,
                                  "\n  #{' ' * block_start_col}")
        end

        def block_arg_string(args)
          args.children.map do |arg|
            if arg.mlhs_type?
              "(#{block_arg_string(arg)})"
            else
              arg.source
            end
          end.join(', ')
        end
      end
    end
  end
end
