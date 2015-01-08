# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the pre 1.9 lambda syntax for one-line
      # anonymous functions and uses of the 1.9 lambda syntax for multi-line
      # anonymous functions.
      class Lambda < Cop
        SINGLE_MSG = 'Use the new lambda literal syntax `->(params) {...}`.'
        SINGLE_NO_ARG_MSG = 'Use the new lambda literal syntax `-> {...}`.'
        MULTI_MSG = 'Use the `lambda` method for multi-line lambdas.'

        TARGET = s(:send, nil, :lambda)

        def on_block(node)
          # We're looking for
          # (block
          #   (send nil :lambda)
          #   ...)
          block_method, args, = *node

          return unless block_method == TARGET
          selector = block_method.loc.selector.source
          lambda_length = lambda_length(node)

          if selector != '->' && lambda_length == 0
            add_offense_for_single_line(block_method, args)
          elsif selector == '->' && lambda_length > 0
            add_offense(block_method, :expression, MULTI_MSG)
          end
        end

        private

        def add_offense_for_single_line(block_method, args)
          if args.children.empty?
            add_offense(block_method, :expression, SINGLE_NO_ARG_MSG)
          else
            add_offense(block_method, :expression, SINGLE_MSG)
          end
        end

        def lambda_length(block_node)
          start_line = block_node.loc.begin.line
          end_line = block_node.loc.end.line

          end_line - start_line
        end

        def autocorrect(node)
          ancestor = node.ancestors.first

          @corrections << lambda do |corrector|
            if node.loc.expression.source == 'lambda'
              autocorrect_old_to_new(corrector, ancestor)
            else
              autocorrect_new_to_old(corrector, ancestor)
            end
          end
        end

        def autocorrect_new_to_old(corrector, node)
          block_method, args = *node
          corrector.replace(block_method.loc.expression, 'lambda')
          return if args.children.empty?

          arg_str = " |#{lambda_arg_string(args)}|"
          corrector.remove(args.loc.expression)
          corrector.insert_after(node.loc.begin, arg_str)
        end

        def autocorrect_old_to_new(corrector, node)
          block_method, args = *node
          corrector.replace(block_method.loc.expression, '->')
          return if args.children.empty?

          arg_str = "(#{lambda_arg_string(args)})"
          whitespace_and_old_args = node.loc.begin.end.join(args.loc.end)
          corrector.insert_after(block_method.loc.expression, arg_str)
          corrector.remove(whitespace_and_old_args)
        end

        def lambda_arg_string(args)
          args.children.map { |a| a.loc.expression.source }.join(', ')
        end
      end
    end
  end
end
