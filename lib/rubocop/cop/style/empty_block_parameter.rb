# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for delimiters that are pipes or braces for empty
      # block parameters. Delimiters for empty block parameters do not cause
      # syntax errors, but it looks strange.
      #
      # @example
      #   # bad
      #   a do ||
      #     do_something
      #   end
      #
      #   # bad
      #   a { || do_something }
      #
      #   # good
      #   a do
      #   end
      #
      #   # good
      #   a { do_something }
      class EmptyBlockParameter < Cop
        MSG = 'Omit delimiters for the empty block parameters.'.freeze

        def_node_matcher :empty_arguments?, <<-PATTERN
          (block _ $(args) _)
        PATTERN

        def on_block(node)
          empty_arguments?(node) do |args|
            return unless args.loc.expression
            add_offense(args)
          end
        end

        private

        def autocorrect(node)
          block = node.parent
          send_node = block.send_node
          if send_node.source == '->'
            autocorrect_lambda(send_node, node)
          else
            autocorrect_block(block, node)
          end
        end

        def autocorrect_lambda(send_node, args)
          lambda do |corrector|
            range = range_between(
              send_node.loc.expression.end_pos,
              args.loc.expression.end_pos
            )
            corrector.remove(range)
          end
        end

        def autocorrect_block(block, args)
          lambda do |corrector|
            range = range_between(
              block.loc.begin.end_pos,
              args.loc.expression.end_pos
            )
            corrector.remove(range)
          end
        end
      end
    end
  end
end
