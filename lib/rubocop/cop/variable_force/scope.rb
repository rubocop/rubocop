# encoding: utf-8

module RuboCop
  module Cop
    class VariableForce
      # A Scope represents a context of local variable visibility.
      # This is a place where local variables belong to.
      # A scope instance holds a scope node and variable entries.
      class Scope
        attr_reader :node, :variables

        def initialize(node)
          # Accept begin node for top level scope.
          unless SCOPE_TYPES.include?(node.type) || node.type == :begin
            fail ArgumentError,
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
          case @node.type
          when :def  then @node.children[0]
          when :defs then @node.children[1]
          else nil # TODO
          end
        end

        def body_node
          child_index = case @node.type
                        when :top_level           then 0
                        when :module, :sclass     then 1
                        when :def, :class, :block then 2
                        when :defs                then 3
                        end

          @node.children[child_index]
        end
      end
    end
  end
end
