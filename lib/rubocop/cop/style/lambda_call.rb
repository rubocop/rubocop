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
      class LambdaCall < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        RESTRICT_ON_SEND = %i[call].freeze

        def on_send(node)
          return unless node.receiver

          if offense?(node)
            add_offense(node) do |corrector|
              opposite_style_detected
              autocorrect(corrector, node)
            end
          else
            correct_style_detected
          end
        end

        def autocorrect(corrector, node)
          if explicit_style?
            receiver = node.receiver.source
            replacement = node.source.sub("#{receiver}.", "#{receiver}.call")

            corrector.replace(node, replacement)
          else
            add_parentheses(node, corrector) unless node.parenthesized?
            corrector.remove(node.loc.selector)
          end
        end

        private

        def offense?(node)
          explicit_style? && node.implicit_call? ||
            implicit_style? && !node.implicit_call?
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
