# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking modifier nodes.
    module AccessModifierNode
      extend NodePattern::Macros

      def_node_matcher :private_node?, '(send nil :private)'
      def_node_matcher :protected_node?, '(send nil :protected)'
      def_node_matcher :public_node?, '(send nil :public)'
      def_node_matcher :module_function_node?, '(send nil :module_function)'

      # Returns true when the node is an access modifier.
      def modifier_node?(node)
        modifier_structure?(node) && class_or_module_parent?(node)
      end

      # Returns true when the node looks like an access modifier.
      def modifier_structure?(node)
        private_node?(node) ||
          protected_node?(node) ||
          public_node?(node) ||
          module_function_node?(node)
      end

      # Returns true when the parent of what looks like an access modifier
      # is a Class or Module. Filters out simple method calls to similarly
      # named private, protected or public.
      def class_or_module_parent?(node)
        node.each_ancestor do |ancestor|
          if ancestor.block_type?
            return true if ancestor.class_constructor?
          elsif !ancestor.begin_type?
            return %i(casgn sclass class module).include?(ancestor.type)
          end
        end
      end
    end
  end
end
