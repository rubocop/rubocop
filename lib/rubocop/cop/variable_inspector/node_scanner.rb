# encoding: utf-8

module Rubocop
  module Cop
    module VariableInspector
      # This provides a way to scan all nodes only in current scope.
      class NodeScanner
        TWISTED_SCOPE_NODE_TYPES = [:block, :sclass, :defs].freeze
        POST_CONDITION_LOOP_NODE_TYPES = [:while_post, :until_post].freeze

        def self.scan_nodes_in_scope(origin_node, &block)
          instance = new(block)
          instance.scan_nodes_in_scope(origin_node)
        end

        def initialize(callback)
          @callback = callback
        end

        def scan_nodes_in_scope(origin_node, yield_origin_node = false)
          @callback.call(origin_node) if yield_origin_node

          origin_node.children.each_with_index do |child, index|
            next unless child.is_a?(Parser::AST::Node)
            node = child

            if index == 0 &&
               TWISTED_SCOPE_NODE_TYPES.include?(origin_node.type)
              next
            end

            @callback.call(node)

            scan_children(node)
          end
        end

        def scan_children(node)
          case node.type
          when *POST_CONDITION_LOOP_NODE_TYPES
            # Loop body nodes need to be scanned first.
            #
            # Ruby:
            #   begin
            #     foo = 1
            #   end while foo > 10
            #   puts foo
            #
            # AST:
            #   (begin
            #     (while-post
            #       (send
            #         (lvar :foo) :>
            #         (int 10))
            #       (kwbegin
            #         (lvasgn :foo
            #           (int 1))))
            #     (send nil :puts
            #       (lvar :foo)))
            scan_nodes_in_scope(node.children[1], true)
            scan_nodes_in_scope(node.children[0], true)
          when *TWISTED_SCOPE_NODE_TYPES
            # The variable foo belongs to the top level scope,
            # but in AST, it's under the block node.
            #
            # Ruby:
            #   some_method(foo = 1) do
            #   end
            #   puts foo
            #
            # AST:
            #   (begin
            #     (block
            #       (send nil :some_method
            #         (lvasgn :foo
            #           (int 1)))
            #       (args) nil)
            #     (send nil :puts
            #       (lvar :foo)))
            #
            # So the the method argument nodes need to be processed
            # in current scope.
            #
            # Same thing.
            #
            # Ruby:
            #   instance = Object.new
            #   class << instance
            #     foo = 1
            #   end
            #
            # AST:
            #   (begin
            #     (lvasgn :instance
            #       (send
            #         (const nil :Object) :new))
            #     (sclass
            #       (lvar :instance)
            #       (begin
            #         (lvasgn :foo
            #           (int 1))
            scan_nodes_in_scope(node.children.first, true)
          when *SCOPE_TYPES
            # Do not go into inner scope.
          else
            scan_nodes_in_scope(node)
          end
        end
      end
    end
  end
end
