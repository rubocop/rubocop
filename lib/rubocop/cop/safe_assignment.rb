# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for safe assignment. By safe assignment we mean
    # putting parentheses around an assignment to indicate "I know I'm using an
    # assignment as a condition. It's not a mistake."
    module SafeAssignment
      def safe_assignment?(node)
        node.type == :begin && node.children.size == 1 &&
          Util::EQUALS_ASGN_NODES.include?(node.children[0].type)
      end

      def safe_assignment_allowed?
        cop_config['AllowSafeAssignment']
      end
    end
  end
end
