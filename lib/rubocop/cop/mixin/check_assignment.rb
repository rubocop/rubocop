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
        return unless node.setter_method?

        rhs = extract_rhs(node)

        return unless rhs

        check_assignment(node, rhs)
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
          rhs = node.last_argument
        end

        rhs
      end
    end
  end
end
