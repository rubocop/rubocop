# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Certain numeric operations have a constant result, usually 0 or 1.
      # Subtracting a number from itself or multiplying it by 0 will always return 0.
      # Additionally, a variable modulo 0 or itself will always return 0.
      # Dividing a number by itself or raising it to the power of 0 will always return 1.
      # As such, they can be replaced with that result.
      # These are probably leftover from debugging, or are mistakes.
      # Other numeric operations that are similarly leftover from debugging or mistakes
      # are handled by Lint/UselessNumericOperation.
      #
      # @example
      #
      #   # bad
      #   x - x
      #   x * 0
      #   x % 1
      #   x % x
      #
      #   # good
      #   0
      #
      #   # bad
      #   x -= x
      #   x *= 0
      #   x %= 1
      #   x %= x
      #
      #   # good
      #   x = 0
      #
      #   # bad
      #   x / x
      #   x ** 0
      #
      #   # good
      #   1
      #
      #   # bad
      #   x /= x
      #   x **= 0
      #
      #   # good
      #   x = 1
      #
      class NumericOperationWithConstantResult < Base
        extend AutoCorrector
        MSG = 'Numeric operation with a constant result detected.'
        RESTRICT_ON_SEND = %i[- * / % **].freeze

        # @!method operation_with_constant_result?(node)
        def_node_matcher :operation_with_constant_result?,
                         '(send (send nil? $_) $_ ({int | send nil?} $_))'

        # @!method abbreviated_assignment_with_constant_result?(node)
        def_node_matcher :abbreviated_assignment_with_constant_result?,
                         '(op-asgn (lvasgn $_) $_ ({int | lvar} $_))'

        def on_send(node)
          return unless operation_with_constant_result?(node)

          variable, operation, number = operation_with_constant_result?(node)
          result = constant_result?(variable, operation, number)
          return unless result

          add_offense(node) do |corrector|
            corrector.replace(node, result.to_s)
          end
        end

        def on_op_asgn(node)
          return unless abbreviated_assignment_with_constant_result?(node)

          variable, operation, number = abbreviated_assignment_with_constant_result?(node)
          result = constant_result?(variable, operation, number)
          return unless result

          add_offense(node) do |corrector|
            corrector.replace(node, "#{variable} = #{result}")
          end
        end

        private

        # rubocop :disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        def constant_result?(variable, operation, number)
          if number.to_s == '0'
            return 0 if operation == :*
            return 1 if operation == :**
          elsif number.to_s == '1'
            return 0 if operation == :%
          elsif number == variable
            return 0 if %i[- %].include?(operation)
            return 1 if operation == :/
          end
          # If we weren't able to find any matches, return false so we can bail out.
          false
        end
        # rubocop :enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      end
    end
  end
end
