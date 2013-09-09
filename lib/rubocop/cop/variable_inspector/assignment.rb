# encoding: utf-8

module Rubocop
  module Cop
    module VariableInspector
      # This class represents each assignment of a variable.
      class Assignment
        BRANCH_TYPES = [:if, :case].freeze
        CONDITION_INDEX_OF_BRANCH_NODE = 0

        LOGICAL_OPERATOR_TYPES = [:and, :or].freeze
        LEFT_SIDE_INDEX_OF_LOGICAL_OPERATOR_NODE = 0

        ENSURE_TYPE = :ensure
        ENSURE_INDEX_OF_ENSURE_NODE = 1

        MULTIPLE_LEFT_HAND_SIDE_TYPE = :mlhs

        REFERENCE_PENETRABLE_BRANCH_TYPES = %w(rescue_main ensure_main).freeze

        attr_reader :node, :referenced
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

        def reference!
          @referenced = true
        end

        def used?
          @variable.captured_by_block? || @referenced
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

        def inside_of_branch?
          !branch_point_node.nil?
        end

        def reference_penetrable?
          REFERENCE_PENETRABLE_BRANCH_TYPES.include?(branch_type)
        end

        def branch_id
          return nil unless inside_of_branch?
          @branch_id ||= [branch_point_node.object_id, branch_type].join('_')
        end

        def branch_type
          return nil unless inside_of_branch?
          @branch_type ||= [branch_point_node.type, branch_body_name].join('_')
        end

        # Inner if, case, rescue, or ensure node.
        def branch_point_node
          if instance_variable_defined?(:@branch_point_node)
            return @branch_point_node
          end

          set_branch_point_and_body_nodes!
          @branch_point_node
        end

        # A child node of #branch_point_node this assignment belongs.
        def branch_body_node
          if instance_variable_defined?(:@branch_body_node)
            return @branch_body_node
          end

          set_branch_point_and_body_nodes!
          @branch_body_node
        end

        def parent_node
          ancestor_nodes_in_scope.last
        end

        def grantparent_node
          ancestor_nodes_in_scope[-2]
        end

        def ancestor_nodes_in_scope
          @ancestor_nodes_in_scope ||= @variable.scope.ancestors_of_node(@node)
        end

        private

        def branch_body_name
          case branch_point_node.type
          when :if
            if_body_name
          when :case
            case_body_name
          when *LOGICAL_OPERATOR_TYPES
            logical_operator_body_name
          when RESCUE_TYPE
            rescue_body_name
          when ENSURE_TYPE
            ensure_body_name
          else
            fail InvalidBranchBodyError
          end
        rescue InvalidBranchBodyError
          raise InvalidBranchBodyError,
                "Invalid body index #{body_index} of #{branch_point_node.type}"
        end

        def if_body_name
          case body_index
          when 1 then 'true'
          when 2 then 'false'
          else fail InvalidBranchBodyError
          end
        end

        def case_body_name
          if branch_body_node.type == :when
            "when#{body_index - 1}"
          else
            'else'
          end
        end

        def logical_operator_body_name
          case body_index
          when 1 then 'right'
          else fail InvalidBranchBodyError
          end
        end

        def rescue_body_name
          if body_index == 0
            'main'
          elsif branch_body_node.type == :resbody
            "rescue#{body_index - 1}"
          else
            'else'
          end
        end

        def ensure_body_name
          case body_index
          when 0 then 'main'
          else fail InvalidBranchBodyError
          end
        end

        def body_index
          branch_point_node.children.index(branch_body_node)
        end

        def set_branch_point_and_body_nodes!
          ancestors_and_self_nodes = ancestor_nodes_in_scope + [@node]

          ancestors_and_self_nodes.reverse.each_cons(2) do |child, parent|
            next unless branch?(parent, child)
            @branch_point_node = parent
            @branch_body_node = child
            break
          end
        end

        def branch?(parent_node, child_node)
          child_index = parent_node.children.index(child_node)

          case parent_node.type
          when *BRANCH_TYPES
            child_index != CONDITION_INDEX_OF_BRANCH_NODE
          when *LOGICAL_OPERATOR_TYPES
            child_index != LEFT_SIDE_INDEX_OF_LOGICAL_OPERATOR_NODE
          when RESCUE_TYPE
            true
          when ENSURE_TYPE
            child_index != ENSURE_INDEX_OF_ENSURE_NODE
          else
            false
          end
        end

        class InvalidBranchBodyError < StandardError; end
      end
    end
  end
end
