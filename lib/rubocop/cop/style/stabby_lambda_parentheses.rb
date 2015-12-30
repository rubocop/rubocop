# encoding: utf-8
module RuboCop
  module Cop
    module Style
      # Check for parentheses around stabby lambda arguments.
      # There are two different styles. Defaults to `require_parentheses`.
      #
      # @example
      #   # require_parentheses - bad
      #   ->a,b,c { a + b + c }
      #
      #   # require_parentheses - good
      #   ->(a,b,c) { a + b + c}
      #
      #   # require_no_parentheses - bad
      #   ->(a,b,c) { a + b + c }
      #
      #   # require_parentheses - good
      #   ->a,b,c { a + b + c}
      class StabbyLambdaParentheses < Cop
        include ConfigurableEnforcedStyle

        MSG_REQUIRE = 'Wrap stabby lambda arguments with parentheses.'
        MSG_NO_REQUIRE = 'Do not wrap stabby lambda arguments with parentheses.'
        ARROW = '->'.freeze

        def on_send(node)
          return unless arrow_lambda_with_args?(node)

          if style == :require_parentheses
            if parentheses?(node)
              correct_style_detected
            else
              missing_parentheses(node)
            end
          elsif parentheses?(node)
            unwanted_parentheses(node)
          else
            correct_style_detected
          end
        end

        def autocorrect(node)
          if style == :require_parentheses
            missing_parentheses_corrector(node)
          elsif style == :require_no_parentheses
            unwanted_parentheses_corrector(node)
          end
        end

        private

        def missing_parentheses(node)
          add_offense(node_args(node), :expression, MSG_REQUIRE) do
            opposite_style_detected
          end
        end

        def unwanted_parentheses(node)
          add_offense(node_args(node), :expression, MSG_NO_REQUIRE) do
            opposite_style_detected
          end
        end

        def missing_parentheses_corrector(node)
          lambda do |corrector|
            args_loc = node_args(node).loc.expression

            corrector.insert_before(args_loc, '(')
            corrector.insert_after(args_loc, ')')
          end
        end

        def unwanted_parentheses_corrector(node)
          lambda do |corrector|
            args_loc = node_args(node).loc

            corrector.replace(args_loc.begin, '')
            corrector.remove(args_loc.end)
          end
        end

        def arrow_lambda_with_args?(node)
          lambda_node?(node) && arrow_form?(node) && args?(node)
        end

        def lambda_node?(node)
          receiver, call = *node
          receiver.nil? && call == :lambda
        end

        def arrow_form?(node)
          node.loc.selector.source == ARROW
        end

        def node_args(node)
          _call, args, _body = *node.parent
          args
        end

        def args?(node)
          args = node_args(node)
          args.children.count > 0
        end

        def parentheses?(node)
          args = node_args(node)
          args.loc.begin
        end
      end
    end
  end
end
