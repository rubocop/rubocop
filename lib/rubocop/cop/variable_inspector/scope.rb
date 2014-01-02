# encoding: utf-8

module Rubocop
  module Cop
    module VariableInspector
      # A Scope represents a context of local variable visibility.
      # This is a place where local variables belong to.
      # A scope instance holds a scope node and variable entries.
      class Scope
        attr_reader :node, :variables

        def initialize(node)
          # Accept begin node for top level scope.
          unless SCOPE_TYPES.include?(node.type) || node.type == :begin
            fail ArgumentError,
                 "Node type must be any of #{SCOPE_TYPES}, " +
                 "passed #{node.type}"
          end
          @node = node
          @variables = {}
        end

        def ==(other)
          @node.equal?(other.node)
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

        def ancestors_of_node(target_node)
          ASTScanner.scan(@node) do |scanning_node, ancestor_nodes|
            return ancestor_nodes[1..-1] if scanning_node.equal?(target_node)
          end

          fail "Node #{target_node} is not found in scope #{@node}"
        end

        # This class provides a ways to scan AST with tracking ancestor nodes.
        class ASTScanner
          def self.scan(node, &block)
            new.scan(node, &block)
          end

          def initialize
            @ancestor_nodes = []
          end

          def scan(node, &block)
            @ancestor_nodes.push(node)

            node.children.each do |child|
              next unless child.is_a?(Parser::AST::Node)
              yield child, @ancestor_nodes
              scan(child, &block)
            end

            @ancestor_nodes.pop
          end
        end
      end
    end
  end
end
