# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks that node destructuring is done either using the node
      # extensions or using a splat.
      #
      # @example Using splat expansion
      #
      #   # bad
      #   receiver, method_name, arguments = send_node.children
      #
      #   # good
      #   receiver, method_name, arguments = *send_node
      #
      # @example Using node extensions
      #
      #   # bad
      #   _receiver, method_name, _arguments = send_node.children
      #
      #   # good
      #   method_name = send_node.method_name
      class NodeDestructuring < Cop
        MSG = 'Use the methods provided with the node extensions, or ' \
              'destructure the node using `*`.'.freeze

        def_node_matcher :node_children_destructuring?, <<-PATTERN
          (masgn (mlhs ...) (send (send nil? [#node_suffix? _]) :children))
        PATTERN

        def on_masgn(node)
          node_children_destructuring?(node) do
            add_offense(node)
          end
        end

        private

        def node_suffix?(method_name)
          method_name.to_s.end_with?('node')
        end
      end
    end
  end
end
