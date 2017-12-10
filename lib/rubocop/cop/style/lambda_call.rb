# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for use of the lambda.(args) syntax.
      #
      # @example EnforcedStyle: call (default)
      #  # bad
      #  lambda.(x, y)
      #
      #  # good
      #  lambda.call(x, y)
      #
      # @example EnforcedStyle: braces
      #  # bad
      #  lambda.call(x, y)
      #
      #  # good
      #  lambda.(x, y)
      class LambdaCall < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          return unless node.receiver && node.method?(:call)

          if offense?(node)
            add_offense(node) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if explicit_style?
              receiver = node.receiver.source
              replacement = node.source.sub("#{receiver}.", "#{receiver}.call")

              corrector.replace(node.source_range, replacement)
            else
              add_parentheses(node, corrector) unless node.parenthesized?
              corrector.remove(node.loc.selector)
            end
          end
        end

        private

        def offense?(node)
          explicit_style? && node.implicit_call? ||
            implicit_style? && !node.implicit_call?
        end

        def add_parentheses(node, corrector)
          if node.arguments.empty?
            corrector.insert_after(node.source_range, '()')
          else
            corrector.replace(args_begin(node), '(')
            corrector.insert_after(args_end(node), ')')
          end
        end

        def args_begin(node)
          loc = node.loc
          selector =
            node.super_type? || node.yield_type? ? loc.keyword : loc.selector
          selector.end.resize(1)
        end

        def args_end(node)
          node.loc.expression.end
        end

        def message(_node)
          if explicit_style?
            'Prefer the use of `lambda.call(...)` over `lambda.(...)`.'
          else
            'Prefer the use of `lambda.(...)` over `lambda.call(...)`.'
          end
        end

        def implicit_style?
          style == :braces
        end

        def explicit_style?
          style == :call
        end
      end
    end
  end
end
