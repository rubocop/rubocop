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
        include ConfigurableEnforcedStyle

        def on_send(node)
          _receiver, selector, = *node

          # we care only about `call` methods
          return unless selector == :call

          if offence?(node)
            add_offence(node, :expression) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        private

        def offence?(node)
          # lambda.() does not have a selector
          style == :call && node.loc.selector.nil? ||
            style == :braces && node.loc.selector
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if style == :call
              receiver_node, = *node
              expr = node.loc.expression
              receiver = receiver_node.loc.expression.source
              replacement = expr.source.sub("#{receiver}.", "#{receiver}.call")
              corrector.replace(expr, replacement)
            else
              corrector.remove(node.loc.selector)
            end
          end
        end

        def message(node)
          if style == :call
            'Prefer the use of `lambda.call(...)` over `lambda.(...)`.'
          else
            'Prefer the use of `lambda.(...)` over `lambda.call(...)`.'
          end
        end
      end
    end
  end
end
