# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for use of the lambda.(args) syntax.
      #
      # @example
      #
      #  # bad
      #  lambda.(x, y)
      #
      #  # good
      #  lambda.call(x, y)
      class LambdaCall < Cop
        MSG = 'Prefer the use of `lambda.call(...)` over `lambda.(...)`.'

        def on_send(node)
          _receiver, selector, = *node

          # lambda.() does not have a selector
          return unless selector == :call && node.loc.selector.nil?

          convention(node, :expression)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            receiver_node, = *node
            expr = node.loc.expression
            receiver = receiver_node.loc.expression.source
            replacement = expr.source.sub("#{receiver}.", "#{receiver}.call")
            corrector.replace(expr, replacement)
          end
        end
      end
    end
  end
end
