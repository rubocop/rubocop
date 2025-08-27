# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant argument to `raise` when re-raising exceptions.
      #
      # @example
      #
      #   # bad
      #   begin
      #     code_that_can_fail
      #   rescue StandardError => e
      #     logger.error "Operation failed: #{e.message}"
      #
      #     raise e
      #   end
      #
      #   # good
      #   begin
      #     code_that_can_fail
      #   rescue StandardError => e
      #     logger.error "Operation failed: #{e.message}"
      #
      #     raise
      #   end
      #
      class RedundantRaiseArgument < Base
        extend AutoCorrector

        MSG = 'Remove redundant argument to `%<method>s`.'

        # @!method locale_variable_assignment?(node)
        def_node_matcher :locale_variable_assignment?, <<~PATTERN
          (lvasgn %1 ...)
        PATTERN

        # @!method raise_with_exception_argument?(node)
        def_node_matcher :raise_with_exception_argument?, <<~PATTERN
          (send nil? {:raise :fail} (lvar %1))
        PATTERN

        def on_resbody(node)
          return unless (exception_variable_name = node.exception_variable&.name)

          node.body&.each_descendant(:lvasgn, :send) do |descendant|
            break if locale_variable_assignment?(descendant, exception_variable_name)
            next unless raise_with_exception_argument?(descendant, exception_variable_name)

            register_offense(descendant)
          end
        end

        private

        def register_offense(node)
          add_offense(node.first_argument,
                      message: format(MSG, method: node.method_name)) do |corrector|
            corrector.replace(node, node.method_name)
          end
        end
      end
    end
  end
end
