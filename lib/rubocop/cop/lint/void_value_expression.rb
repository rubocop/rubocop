# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      SKIPPABLE_STATEMENTS = %i[kwbegin if while begin rescue ensure resbody].freeze
      LIMIT_STATEMENTS = %i[def defs block case when case_match in_pattern].freeze
      CONTROL_STATEMENTS = %i[or and].freeze

      class VoidValueExpression < Base
        def on_return(return_node)
          relevant_ancestry = filter_relevant_ancestry(return_node)
          parent_node = relevant_ancestry.first

          return unless parent_node
          return unless parent_node.value_used? || %i[lvasgn send].include?(parent_node.type)
          return if in_control_statement_but_not_first?(return_node, parent_node)

          add_offense(return_node.loc.keyword, message: 'This return introduces a void value.')
        end

        private

        def in_control_statement_but_not_first?(node, parent)
          CONTROL_STATEMENTS.include?(parent.type) && parent.children.first != node
        end

        def filter_relevant_ancestry(node)
          node
            .ancestors
            .take_while { |n| !LIMIT_STATEMENTS.include?(n.type) }
            .reject { |n| SKIPPABLE_STATEMENTS.include?(n.type) }
        end
      end
    end
  end
end
