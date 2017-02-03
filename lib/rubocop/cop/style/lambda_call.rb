# frozen_string_literal: true

module RuboCop
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
          return unless node.receiver && node.method?(:call)

          if offense?(node)
            add_offense(node, :expression) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        private

        def offense?(node)
          explicit_style? && node.implicit_call? ||
            implicit_style? && !node.implicit_call?
        end

        def autocorrect(node)
          lambda do |corrector|
            if explicit_style?
              receiver = node.receiver.source
              replacement = node.source.sub("#{receiver}.", "#{receiver}.call")

              corrector.replace(node.source_range, replacement)
            else
              corrector.remove(node.loc.selector)
            end
          end
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
