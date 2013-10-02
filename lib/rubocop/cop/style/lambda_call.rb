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
        def on_send(node)
          _receiver, selector, = *node

          # we care only about `call` methods
          return unless selector == :call

          if style == :call && node.loc.selector.nil?
            # lambda.() does not have a selector
            convention(node, :expression)
          elsif style == :braces && node.loc.selector
            convention(node, :expression)
          end
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

        private

        def style
          case cop_config['EnforcedStyle']
          when 'call' then :call
          when 'braces' then :braces
          else fail 'Unknown style selected!'
          end
        end
      end
    end
  end
end
