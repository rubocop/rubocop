# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for parentheses for empty lambda parameters. Parentheses
      # for empty lambda parameters do not cause syntax errors, but they are
      # redundant.
      #
      # @example
      #   # bad
      #   -> () { do_something }
      #
      #   # good
      #   -> { do_something }
      #
      #   # good
      #   -> (arg) { do_something(arg) }
      class EmptyLambdaParameter < Cop
        include EmptyParameter

        MSG = 'Omit parentheses for the empty lambda parameters.'.freeze

        def on_block(node)
          send_node = node.send_node
          return unless send_node.send_type?
          check(node) if node.send_node.stabby_lambda?
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            send_node = node.parent.send_node
            range = range_between(
              send_node.loc.expression.end_pos,
              node.loc.expression.end_pos
            )
            corrector.remove(range)
          end
        end
      end
    end
  end
end
