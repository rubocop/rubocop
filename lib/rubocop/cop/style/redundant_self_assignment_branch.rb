# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for places where conditional branch makes redundant self-assignment.
      #
      # It only detects local variable because it may replace state of instance variable,
      # class variable, and global variable that have state across methods with `nil`.
      #
      # @example
      #
      #   # bad
      #   foo = condition ? bar : foo
      #
      #   # good
      #   foo = bar if condition
      #
      #   # bad
      #   foo = condition ? foo : bar
      #
      #   # good
      #   foo = bar unless condition
      #
      class RedundantSelfAssignmentBranch < Base
        include RescueNode
        extend AutoCorrector

        MSG = 'Remove the self-assignment branch.'

        STATEMENT_BODY_TYPES = %i[
          kwbegin def defs block numblock itblock class module sclass rescue ensure
        ].freeze

        def on_lvasgn(node)
          expression = node.expression

          return unless use_if_and_else_branch?(expression)
          return unless statement?(node)

          if_branch = expression.if_branch
          else_branch = expression.else_branch
          return if inconvertible_to_modifier?(if_branch, else_branch)

          if self_assign?(node.name, if_branch)
            register_offense(expression, if_branch, else_branch, 'unless')
          elsif self_assign?(node.name, else_branch)
            register_offense(expression, else_branch, if_branch, 'if')
          end
        end

        private

        def use_if_and_else_branch?(expression)
          return false unless expression&.if_type?

          !expression.ternary? || !expression.else?
        end

        def statement?(node)
          parent = node.parent
          return true if parent.nil? || parent.type?(*STATEMENT_BODY_TYPES)
          return parent.loc.begin.nil? if parent.begin_type?
          return !rescue_modifier?(parent) if parent.resbody_type?

          statement_branch?(node, parent)
        end

        def statement_branch?(node, parent)
          case parent.type
          when :if
            !parent.ternary? && !node.equal?(parent.condition)
          when :when, :in_pattern, :while, :until, :for
            node.equal?(parent.body)
          when :case, :case_match
            node.equal?(parent.else_branch)
          else
            false
          end
        end

        def inconvertible_to_modifier?(if_branch, else_branch)
          multiple_statements?(if_branch) || multiple_statements?(else_branch) ||
            (else_branch.respond_to?(:elsif?) && else_branch.elsif?)
        end

        def multiple_statements?(branch)
          return false unless branch&.begin_type?

          !branch.children.empty?
        end

        def self_assign?(variable, branch)
          variable.to_s == branch&.source
        end

        def register_offense(if_node, offense_branch, opposite_branch, keyword)
          add_offense(offense_branch) do |corrector|
            assignment_value = opposite_branch ? opposite_branch.source : 'nil'
            replacement = "#{assignment_value} #{keyword} #{if_node.condition.source}"
            if opposite_branch.respond_to?(:heredoc?) && opposite_branch.heredoc?
              replacement += opposite_branch.loc.heredoc_end.with(
                begin_pos: opposite_branch.source_range.end_pos
              ).source
            end

            corrector.replace(if_node, replacement)
          end
        end
      end
    end
  end
end
