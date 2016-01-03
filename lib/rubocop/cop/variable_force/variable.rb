# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    class VariableForce
      # A Variable represents existence of a local variable.
      # This holds a variable declaration node,
      # and some states of the variable.
      class Variable
        VARIABLE_DECLARATION_TYPES =
          (VARIABLE_ASSIGNMENT_TYPES + ARGUMENT_DECLARATION_TYPES).freeze

        attr_reader :name, :declaration_node, :scope,
                    :assignments, :references, :captured_by_block
        alias captured_by_block? captured_by_block

        def initialize(name, declaration_node, scope)
          unless VARIABLE_DECLARATION_TYPES.include?(declaration_node.type)
            fail ArgumentError,
                 "Node type must be any of #{VARIABLE_DECLARATION_TYPES}, " \
                 "passed #{declaration_node.type}"
          end

          @name = name.to_sym
          @declaration_node = declaration_node
          @scope = scope

          @assignments = []
          @references = []
          @captured_by_block = false
        end

        def assign(node)
          @assignments << Assignment.new(node, self)
        end

        def referenced?
          !@references.empty?
        end

        def reference!(node)
          reference = Reference.new(node, @scope)
          @references << reference
          consumed_branch_ids = Set.new

          @assignments.reverse_each do |assignment|
            next if consumed_branch_ids.include?(assignment.branch_id)

            unless assignment.run_exclusively_with?(reference)
              assignment.reference!
            end

            break unless assignment.inside_of_branch?
            break if assignment.branch_id == reference.branch_id
            next if assignment.reference_penetrable?
            consumed_branch_ids << assignment.branch_id
          end
        end

        def capture_with_block!
          @captured_by_block = true
        end

        # This is a convenient way to check whether the variable is used
        # in its entire variable lifetime.
        # For more precise usage check, refer Assignment#used?.
        #
        # Once the variable is captured by a block, we have no idea
        # when, where and how many times the block would be invoked
        # and it means we cannot track the usage of the variable.
        # So we consider it's used to suppress false positive offenses.
        def used?
          @captured_by_block || referenced?
        end

        def should_be_unused?
          name.to_s.start_with?('_')
        end

        def argument?
          ARGUMENT_DECLARATION_TYPES.include?(@declaration_node.type)
        end

        def method_argument?
          argument? && [:def, :defs].include?(@scope.node.type)
        end

        def block_argument?
          argument? && @scope.node.type == :block
        end

        def keyword_argument?
          [:kwarg, :kwoptarg].include?(@declaration_node.type)
        end

        def explicit_block_local_variable?
          @declaration_node.type == :shadowarg
        end
      end
    end
  end
end
