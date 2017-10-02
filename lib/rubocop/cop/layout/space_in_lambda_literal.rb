# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for spaces between -> and opening parameter
      # brace in lambda literals.
      #
      # @example
      #
      #   EnforcedStyle: require_no_space (default)
      #
      #     @bad
      #     a = -> (x, y) { x + y }
      #
      #     @good
      #     a = ->(x, y) { x + y }
      #
      # @example
      #
      #   EnforcedStyle: require_space
      #
      #     @bad
      #     a = ->(x, y) { x + y }
      #
      #     @good
      #     a = -> (x, y) { x + y }
      class SpaceInLambdaLiteral < Cop
        include ConfigurableEnforcedStyle

        ARROW = '->'.freeze
        MSG_REQUIRE_SPACE = 'Use a space between `->` and opening brace ' \
                            'in lambda literals'.freeze
        MSG_REQUIRE_NO_SPACE = 'Do not use spaces between `->` and opening ' \
                               'brace in lambda literals'.freeze

        def on_send(node)
          return unless arrow_lambda_with_args?(node)
          if style == :require_space && !space_after_arrow?(node)
            add_offense(node,
                        location: node.parent.loc.expression,
                        message: MSG_REQUIRE_SPACE)
          elsif style == :require_no_space && space_after_arrow?(node)
            add_offense(node,
                        location: node.parent.loc.expression,
                        message: MSG_REQUIRE_NO_SPACE)
          end
        end

        def autocorrect(lambda_node)
          children = lambda_node.parent.children
          lambda do |corrector|
            if style == :require_space
              corrector.insert_before(children[1].source_range, ' ')
            else
              space_range = range_between(children[0].source_range.end_pos,
                                          children[1].source_range.begin_pos)
              corrector.remove(space_range)
            end
          end
        end

        private

        def arrow_lambda_with_args?(node)
          lambda_node?(node) && arrow_form?(node) && args?(node)
        end

        def lambda_node?(node)
          receiver, call = *node
          receiver.nil? && call == :lambda
        end

        def arrow_form?(lambda_node)
          lambda_node.loc.selector.source == ARROW
        end

        def args?(lambda_node)
          _call, args, _body = *lambda_node.parent
          !args.children.empty?
        end

        def space_after_arrow?(lambda_node)
          arrow = lambda_node.parent.children[0]
          parentheses = lambda_node.parent.children[1]
          parentheses.source_range.begin_pos - arrow.source_range.end_pos > 0
        end
      end
    end
  end
end
