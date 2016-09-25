# frozen_string_literal: true

module RuboCop
  module Cop
    class VariableForce
      # A Scope represents a context of local variable visibility.
      # This is a place where local variables belong to.
      # A scope instance holds a scope node and variable entries.
      class Scope
        OUTER_SCOPE_CHILD_INDICES = {
          defs:   0..0,
          module: 0..0,
          class:  0..1,
          sclass: 0..0,
          block:  0..0
        }.freeze

        attr_reader :node, :variables

        def initialize(node)
          # Accept any node type for top level scope
          unless SCOPE_TYPES.include?(node.type) || !node.parent
            raise ArgumentError,
                  "Node type must be any of #{SCOPE_TYPES}, " \
                  "passed #{node.type}"
          end
          @node = node
          @variables = {}
        end

        def ==(other)
          @node.equal?(other.node)
        end

        def name
          # TODO: Add an else clause
          case @node.type
          when :def  then @node.children[0]
          when :defs then @node.children[1]
          end
        end

        def body_node
          child_index = case @node.type
                        when :module, :sclass     then 1
                        when :def, :class, :block then 2
                        when :defs                then 3
                        end

          child_index ? @node.children[child_index] : @node
        end

        def each_node(&block)
          return to_enum(__method__) unless block_given?
          scan_node(node, &block)
        end

        private

        def scan_node(node, &block)
          yield node unless node.parent

          node.each_child_node do |child_node|
            next if belong_to_another_scope?(child_node)
            yield child_node
            scan_node(child_node, &block)
          end
        end

        def belong_to_another_scope?(node)
          belong_to_outer_scope?(node) || belong_to_inner_scope?(node)
        end

        def belong_to_outer_scope?(target_node)
          return false unless target_node.parent.equal?(node)
          indices = OUTER_SCOPE_CHILD_INDICES[target_node.parent.type]
          return false unless indices
          indices.include?(target_node.sibling_index)
        end

        def belong_to_inner_scope?(target_node)
          return false if target_node.parent.equal?(node)
          return false unless SCOPE_TYPES.include?(target_node.parent.type)
          indices = OUTER_SCOPE_CHILD_INDICES[target_node.parent.type]
          return true unless indices
          !indices.include?(target_node.sibling_index)
        end
      end
    end
  end
end
