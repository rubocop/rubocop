# frozen_string_literal: true

module RuboCop
  module Cop
    class VariableForce
      # A Variable represents existence of a local variable.
      # This holds a variable declaration node and some states of the variable.
      class Variable
        VARIABLE_DECLARATION_TYPES =
          (VARIABLE_ASSIGNMENT_TYPES + ARGUMENT_DECLARATION_TYPES).freeze

        attr_reader :name, :declaration_node, :scope,
                    :assignments, :references, :captured_by_block
        alias captured_by_block? captured_by_block

        def initialize(name, declaration_node, scope)
          unless VARIABLE_DECLARATION_TYPES.include?(declaration_node.type)
            raise ArgumentError,
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
          consumed_branches = Set.new

          @assignments.reverse_each do |assignment|
            next if consumed_branches.include?(assignment.branch)

            unless assignment.run_exclusively_with?(reference)
              assignment.reference!(node)
            end

            break if !assignment.branch || assignment.branch == reference.branch

            unless assignment.branch.may_run_incompletely?
              consumed_branches << assignment.branch
            end
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
        # when, where, and how many times the block would be invoked.
        # This means we cannot track the usage of the variable.
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
          argument? && %i[def defs].include?(@scope.node.type)
        end

        def block_argument?
          argument? && @scope.node.block_type?
        end

        def keyword_argument?
          %i[kwarg kwoptarg].include?(@declaration_node.type)
        end

        def explicit_block_local_variable?
          @declaration_node.shadowarg_type?
        end
      end
    end
  end
end
