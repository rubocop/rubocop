# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the pre 1.9 lambda syntax for one-line
      # anonymous functions and uses of the 1.9 lambda syntax for multi-line
      # anonymous functions.
      class Lambda < Cop
        include AutocorrectUnlessChangingAST

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
          length = lambda_length(node)

          if selector != '->' && length == 1
            add_offense_for_single_line(node, block_method.source_range, args)
          elsif selector == '->' && length > 1
            add_offense(node, block_method.source_range, MULTI_MSG)
          end
        end

        private

        def add_offense_for_single_line(block_node, location, args)
          if args.children.empty?
            add_offense(block_node, location, SINGLE_NO_ARG_MSG)
          else
            add_offense(block_node, location, SINGLE_MSG)
          end
        end

        def lambda_length(block_node)
          start_line = block_node.loc.begin.line
          end_line = block_node.loc.end.line

          end_line - start_line + 1
        end

        def correction(node)
          lambda do |corrector|
            block_method, _args = *node

            if block_method.source == 'lambda'
              autocorrect_old_to_new(corrector, node)
            else
              autocorrect_new_to_old(corrector, node)
            end
          end
        end

        def autocorrect_new_to_old(corrector, node)
          block_method, args = *node
          # Avoid correcting to `lambdado` by inserting whitespace
          # if none exists before or after the lambda arguments.
          if needs_whitespace?(block_method, args, node)
            corrector.insert_before(node.loc.begin, ' ')
          end
          corrector.replace(block_method.source_range, 'lambda')
          corrector.remove(args.source_range) if args.source_range
          return if args.children.empty?
          arg_str = " |#{lambda_arg_string(args)}|"
          corrector.insert_after(node.loc.begin, arg_str)
        end

        def autocorrect_old_to_new(corrector, node)
          block_method, args = *node
          corrector.replace(block_method.source_range, '->')
          return if args.children.empty?

          arg_str = "(#{lambda_arg_string(args)})"
          whitespace_and_old_args = node.loc.begin.end.join(args.loc.end)
          corrector.insert_after(block_method.source_range, arg_str)
          corrector.remove(whitespace_and_old_args)
        end

        def needs_whitespace?(block_method, args, node)
          selector_end = block_method.loc.selector.end.end_pos
          args_begin   = args.loc.begin && args.loc.begin.begin_pos
          args_end     = args.loc.end && args.loc.end.end_pos
          block_begin  = node.loc.begin.begin_pos
          (block_begin == args_end && selector_end == args_begin) ||
            (block_begin == selector_end)
        end

        def lambda_arg_string(args)
          args.children.map(&:source).join(', ')
        end
      end
    end
  end
end
