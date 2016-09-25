# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking modifier nodes.
    module AccessModifierNode
      extend RuboCop::Sexp

      PRIVATE_NODE = s(:send, nil, :private)
      PROTECTED_NODE = s(:send, nil, :protected)
      PUBLIC_NODE = s(:send, nil, :public)
      MODULE_FUNCTION_NODE = s(:send, nil, :module_function)

      # Returns true when the node is an access modifier.
      def modifier_node?(node)
        modifier_structure?(node) && class_or_module_parent?(node)
      end

      # Returns true when the node looks like an access modifier.
      def modifier_structure?(node)
        [PRIVATE_NODE,
         PROTECTED_NODE,
         PUBLIC_NODE,
         MODULE_FUNCTION_NODE].include?(node)
      end

      # Returns true when the parent of what looks like an access modifier
      # is a Class or Module. Filters out simple method calls to similarly
      # named private, protected or public.
      def class_or_module_parent?(node)
        node.each_ancestor do |ancestor|
          if ancestor.block_type?
            return true if ancestor.class_constructor?
          elsif !ancestor.begin_type?
            return [:casgn, :sclass, :class, :module].include?(ancestor.type)
          end
        end
      end
    end
  end
end
