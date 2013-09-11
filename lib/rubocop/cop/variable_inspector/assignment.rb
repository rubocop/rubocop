# encoding: utf-8

module Rubocop
  module Cop
    module VariableInspector
      # This class represents each assignment of a variable.
      class Assignment
        include Locatable

        MULTIPLE_LEFT_HAND_SIDE_TYPE = :mlhs
        REFERENCE_PENETRABLE_BRANCH_TYPES = %w(rescue_main ensure_main).freeze

        attr_reader :node, :variable, :referenced
        alias_method :referenced?, :referenced

        def initialize(node, variable)
          unless VARIABLE_ASSIGNMENT_TYPES.include?(node.type)
            fail ArgumentError,
                 "Node type must be any of #{VARIABLE_ASSIGNMENT_TYPES}, " +
                 "passed #{node.type}"
          end

          @node = node
          @variable = variable
          @referenced = false
        end

        def name
          @node.children.first
        end

        def scope
          @variable.scope
        end

        def reference!
          @referenced = true
        end

        def used?
          @variable.captured_by_block? || @referenced
        end

        def reference_penetrable?
          REFERENCE_PENETRABLE_BRANCH_TYPES.include?(branch_type)
        end

        def regexp_named_capture?
          @node.type == REGEXP_NAMED_CAPTURE_TYPE
        end

        def operator_assignment?
          return false unless meta_assignment_node
          OPERATOR_ASSIGNMENT_TYPES.include?(meta_assignment_node.type)
        end

        def multiple_assignment?
          return false unless meta_assignment_node
          meta_assignment_node.type == MULTIPLE_ASSIGNMENT_TYPE
        end

        def operator
          assignment_node = meta_assignment_node || @node
          assignment_node.loc.operator.source
        end

        def meta_assignment_node
          if instance_variable_defined?(:@meta_assignment_node)
            return @meta_assignment_node
          end

          @meta_assignment_node = nil

          return unless parent_node

          if OPERATOR_ASSIGNMENT_TYPES.include?(parent_node.type) &&
             parent_node.children.index(@node) == 0
            return @meta_assignment_node = parent_node
          end

          return unless grantparent_node

          if parent_node.type == MULTIPLE_LEFT_HAND_SIDE_TYPE &&
             grantparent_node.type == MULTIPLE_ASSIGNMENT_TYPE
            return @meta_assignment_node = grantparent_node
          end

          nil
        end

        private

        def parent_node
          ancestor_nodes_in_scope.last
        end

        def grantparent_node
          ancestor_nodes_in_scope[-2]
        end
      end
    end
  end
end
