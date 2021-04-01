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
        node.left_siblings.reverse.find { |sibling| visibility_block?(sibling) }
      end

      # Navigate to find the last protected method
      def find_visibility_end(node)
        possible_visibilities = VISIBILITY_SCOPES - [node_visibility(node)]
        right = node.right_siblings
        right.find do |child_node|
          possible_visibilities.include?(node_visibility(child_node))
        end || right.last
      end

      def_node_matcher :visibility_block?, <<~PATTERN
        (send nil? { :private :protected :public })
      PATTERN
    end
  end
end
