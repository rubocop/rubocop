# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for checking modifier nodes.
    module AccessModifierNode
      extend AST::Sexp

      PRIVATE_NODE = s(:send, nil, :private)
      PROTECTED_NODE = s(:send, nil, :protected)
      PUBLIC_NODE = s(:send, nil, :public)
      MODUDULE_FUNCTION_NODE = s(:send, nil, :module_function)

      def modifier_node?(node)
        [PRIVATE_NODE,
         PROTECTED_NODE,
         PUBLIC_NODE,
         MODUDULE_FUNCTION_NODE].include?(node)
      end
    end
  end
end
