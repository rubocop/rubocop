# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for checking assignment nodes.
    module CheckAssignment
      TYPES = Util::ASGN_NODES - [:casgn, :op_asgn]
      TYPES.each do |type|
        define_method("on_#{type}") do |node|
          _lhs, rhs = *node
          check_assignment(node, rhs)
        end
      end

      def on_casgn(node)
        _scope, _lhs, rhs = *node
        check_assignment(node, rhs)
      end

      def on_op_asgn(node)
        _lhs, _op, rhs = *node
        check_assignment(node, rhs)
      end

      def on_send(node)
        rhs = node.children.last

        # This will match if, case, begin, blocks, etc.
        check_assignment(node, rhs) if rhs.is_a?(AST::Node)
      end
    end
  end
end
