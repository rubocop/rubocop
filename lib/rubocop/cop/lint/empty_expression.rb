# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the presence of empty expressions.
      #
      # @example
      #
      #   # bad
      #
      #   foo = ()
      #   if ()
      #     bar
      #   end
      #
      # @example
      #
      #   # good
      #
      #   foo = (some_expression)
      #   if (some_expression)
      #     bar
      #   end
      class EmptyExpression < Cop
        MSG = 'Avoid empty expressions.'.freeze

        def on_begin(node)
          return unless empty_expression?(node)

          add_offense(node, node.source_range, MSG)
        end

        private

        def empty_expression?(begin_node)
          begin_node.children.empty?
        end
      end
    end
  end
end
