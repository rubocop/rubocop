# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for safe assignment. By safe assignment we mean
    # putting parentheses around an assignment to indicate "I know I'm using an
    # assignment as a condition. It's not a mistake."
    module SafeAssignment
      def safe_assignment?(node)
        return false unless node.type == :begin
        return false unless node.children.size == 1

        child = node.children.first
        case child.type
        when *Util::EQUALS_ASGN_NODES
          true
        when :send
          _receiver, method_name, _args = *child
          method_name.to_s.end_with?('=')
        else
          false
        end
      end

      def safe_assignment_allowed?
        cop_config['AllowSafeAssignment']
      end
    end
  end
end
