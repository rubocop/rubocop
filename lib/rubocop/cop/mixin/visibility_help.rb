# frozen_string_literal: true

module RuboCop
  module Cop
    # Help methods for determining node visibility.
    module VisibilityHelp
      extend NodePattern::Macros

      VISIBILITY_SCOPES = %i[private protected public].freeze

      private

      def node_visibility(node)
        scope = find_visibility_start(node)
        scope&.method_name || :public
      end

      def find_visibility_start(node)
        left_siblings_of(node)
          .reverse
          .find(&method(:visibility_block?))
      end

      # Navigate to find the last protected method
      def find_visibility_end(node)
        possible_visibilities = VISIBILITY_SCOPES - [node_visibility(node)]
        right = right_siblings_of(node)
        right.find do |child_node|
          possible_visibilities.include?(node_visibility(child_node))
        end || right.last
      end

      def left_siblings_of(node)
        siblings_of(node)[0, node.sibling_index]
      end

      def right_siblings_of(node)
        siblings_of(node)[node.sibling_index..-1]
      end

      def siblings_of(node)
        node.parent.children
      end

      def_node_matcher :visibility_block?, <<~PATTERN
        (send nil? { :private :protected :public })
      PATTERN
    end
  end
end
