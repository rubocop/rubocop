# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks method call operators to not have spaces around them.
      #
      # @example
      #   # bad
      #   foo. bar
      #   foo .bar
      #   foo . bar
      #   foo. bar .buzz
      #   foo
      #     . bar
      #     . buzz
      #   foo&. bar
      #   foo &.bar
      #   foo &. bar
      #   foo &. bar&. buzz
      #   RuboCop:: Cop
      #   RuboCop:: Cop:: Cop
      #   :: RuboCop::Cop
      #
      #   # good
      #   foo.bar
      #   foo.bar.buzz
      #   foo
      #     .bar
      #     .buzz
      #   foo&.bar
      #   foo&.bar&.buzz
      #   RuboCop::Cop
      #   RuboCop::Cop::Cop
      #   ::RuboCop::Cop
      #
      class SpaceAroundMethodCallOperator < Cop
        include SurroundingSpace

        MSG = 'Avoid using spaces around a method call operator.'

        def on_send(node)
          return unless dot_or_safe_navigation_operator?(node)

          check_and_add_offense(node)
        end

        def on_const(node)
          return unless node.loc.double_colon

          check_and_add_offense(node, false)
        end

        def autocorrect(node)
          operator = operator_token(node)
          left = left_token_for_auto_correction(node, operator)
          right = right_token_for_auto_correction(operator)

          lambda do |corrector|
            SpaceCorrector.remove_space(
              processed_source, corrector, left, right
            )
          end
        end

        alias on_csend on_send

        private

        def check_and_add_offense(node, add_left_offense = true)
          operator = operator_token(node)
          left = previous_token(operator)
          right = next_token(operator)

          if !right.comment? && valid_right_token?(right, operator)
            no_space_offenses(node, operator, right, MSG)
          end
          return unless valid_left_token?(left, operator)

          no_space_offenses(node, left, operator, MSG) if add_left_offense
        end

        def operator_token(node)
          operator_location =
            node.const_type? ? node.loc.double_colon : node.loc.dot

          processed_source.find_token do |token|
            token.pos == operator_location
          end
        end

        def previous_token(current_token)
          index = processed_source.tokens.index(current_token)
          index.zero? ? nil : processed_source.tokens[index - 1]
        end

        def next_token(current_token)
          index = processed_source.tokens.index(current_token)
          processed_source.tokens[index + 1]
        end

        def dot_or_safe_navigation_operator?(node)
          node.dot? || node.safe_navigation?
        end

        def valid_left_token?(left, operator)
          left && left.line == operator.line
        end

        def valid_right_token?(right, operator)
          right && right.line == operator.line
        end

        def left_token_for_auto_correction(node, operator)
          left_token = previous_token(operator)
          return operator if node.const_type?
          return left_token if valid_left_token?(left_token, operator)

          operator
        end

        def right_token_for_auto_correction(operator)
          right_token = next_token(operator)
          return right_token if !right_token.comment? && valid_right_token?(right_token, operator)

          operator
        end
      end
    end
  end
end
