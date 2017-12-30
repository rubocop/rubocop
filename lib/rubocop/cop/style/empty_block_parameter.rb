# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for pipes for empty block parameters. Pipes for empty
      # block parameters do not cause syntax errors, but they are redundant.
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
        include EmptyParameter
        include RangeHelp

        MSG = 'Omit pipes for the empty block parameters.'.freeze

        def on_block(node)
          send_node = node.send_node
          check(node) unless send_node.send_type? && send_node.stabby_lambda?
        end

        def autocorrect(node)
          lambda do |corrector|
            block = node.parent
            range = range_between(
              block.loc.begin.end_pos,
              node.loc.expression.end_pos
            )
            corrector.remove(range)
          end
        end
      end
    end
  end
end
