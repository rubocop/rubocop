# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking assignment nodes.
    module CheckAssignment
      Util::ASGN_NODES.each do |type|
        define_method("on_#{type}") do |node|
          check_assignment(node, extract_rhs(node))
        end
      end

      def on_send(node)
        # we only want to indent relative to the receiver
        # when the method called looks like a setter
        return unless node.asgn_method_call?

        # This will match if, case, begin, blocks, etc.
        rhs = extract_rhs(node)
        check_assignment(node, rhs) if rhs.is_a?(AST::Node)
      end

      module_function

      def extract_rhs(node)
        if node.casgn_type?
          _scope, _lhs, rhs = *node
        elsif node.op_asgn_type?
          _lhs, _op, rhs = *node
        elsif Util::ASGN_NODES.include?(node.type)
          _lhs, rhs = *node
        elsif node.send_type?
          rhs = node.children.last
        end

        rhs
      end
    end
  end
end
