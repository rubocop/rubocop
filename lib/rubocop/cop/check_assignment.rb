# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for checking assignment nodes.
    module CheckAssignment
      def on_lvasgn(node)
        _lhs, rhs = *node
        check_assignment(node, rhs)
      end

      def on_ivasgn(node)
        _lhs, rhs = *node
        check_assignment(node, rhs)
      end

      def on_gvasgn(node)
        _lhs, rhs = *node
        check_assignment(node, rhs)
      end

      def on_or_asgn(node)
        _lhs, rhs = *node
        check_assignment(node, rhs)
      end

      def on_and_asgn(node)
        _lhs, rhs = *node
        check_assignment(node, rhs)
      end

      def on_casgn(node)
        _scope, _lhs, rhs = *node
        check_assignment(node, rhs)
      end

      def on_op_asgn(node)
        _lhs, _op, rhs = *node
        check_assignment(node, rhs)
      end
    end
  end
end
