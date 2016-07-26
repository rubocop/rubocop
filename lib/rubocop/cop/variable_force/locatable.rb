# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    class VariableForce
      # This module provides a way to locate the conditional branch the node is
      # in. This is intended to be used as mix-in.
      module Locatable
        BRANCH_TYPES = [:if, :case].freeze
        CONDITION_INDEX_OF_BRANCH_NODE = 0

        LOGICAL_OPERATOR_TYPES = [:and, :or].freeze
        LEFT_SIDE_INDEX_OF_LOGICAL_OPERATOR_NODE = 0

        ENSURE_TYPE = :ensure
        ENSURE_INDEX_OF_ENSURE_NODE = 1

        FOR_LOOP_TYPE = :for
        FOR_LOOP_CHILD_INDEX = 2

        NON_FOR_LOOP_TYPES = LOOP_TYPES - [FOR_LOOP_TYPE]
        NON_FOR_LOOP_TYPES_CHILD_INDEX = 1

        def node
          raise '#node must be declared!'
        end

        def scope
          raise '#scope must be declared!'
        end

        def inside_of_branch?
          branch_point_node
        end

        def run_exclusively_with?(other)
          return false unless branch_point_node.equal?(other.branch_point_node)
          return false if branch_body_node.equal?(other.branch_body_node)

          # Main body of rescue is always run:
          #
          #   begin
          #     # main
          #   rescue
          #     # resbody
          #   end
          if branch_point_node.type == :rescue &&
             (branch_body_name == 'main' || other.branch_body_name == 'main')
            return false
          end

          true
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

        def branch_body_name
          case branch_point_node.type
          when :if                     then if_body_name
          when :case                   then case_body_name
          when RESCUE_TYPE             then rescue_body_name
          when ENSURE_TYPE             then ensure_body_name
          when *LOGICAL_OPERATOR_TYPES then logical_operator_body_name
          when *LOOP_TYPES             then loop_body_name
          else raise InvalidBranchBodyError
          end
        rescue InvalidBranchBodyError
          raise InvalidBranchBodyError,
                "Invalid body index #{body_index} of #{branch_point_node.type}"
        end

        private

        def if_body_name
          case body_index
          when 1 then 'true'
          when 2 then 'false'
          else raise InvalidBranchBodyError
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
          else raise InvalidBranchBodyError
          end
        end

        def rescue_body_name
          if body_index.zero?
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
          else raise InvalidBranchBodyError
          end
        end

        def loop_body_name
          loop_indices = [FOR_LOOP_CHILD_INDEX, NON_FOR_LOOP_TYPES_CHILD_INDEX]

          raise InvalidBranchBodyError unless loop_indices.include?(body_index)

          'main'
        end

        def body_index
          branch_point_node.children.index { |n| n.equal?(branch_body_node) }
        end

        def set_branch_point_and_body_nodes!
          self_and_ancestor_nodes = [node] + ancestor_nodes_in_scope

          self_and_ancestor_nodes.each_cons(2) do |child, parent|
            next unless branch?(parent, child)
            @branch_point_node = parent
            @branch_body_node = child
            break
          end
        end

        def ancestor_nodes_in_scope
          node.each_ancestor.take_while do |ancestor_node|
            !ancestor_node.equal?(scope.node)
          end
        end

        # rubocop:disable Metrics/MethodLength
        def branch?(parent_node, child_node)
          child_index = parent_node.children.index(child_node)

          case parent_node.type
          when RESCUE_TYPE
            true
          when ENSURE_TYPE
            child_index != ENSURE_INDEX_OF_ENSURE_NODE
          when FOR_LOOP_TYPE
            child_index == FOR_LOOP_CHILD_INDEX
          when *BRANCH_TYPES
            child_index != CONDITION_INDEX_OF_BRANCH_NODE
          when *LOGICAL_OPERATOR_TYPES
            child_index != LEFT_SIDE_INDEX_OF_LOGICAL_OPERATOR_NODE
          when *NON_FOR_LOOP_TYPES
            child_index == NON_FOR_LOOP_TYPES_CHILD_INDEX
          else
            false
          end
        end
        # rubocop:enable Metrics/MethodLength

        class InvalidBranchBodyError < StandardError; end
      end
    end
  end
end
