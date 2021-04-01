# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where classes with only class methods can be
      # replaced with a module. Classes should be used only when it makes sense to create
      # instances out of them.
      #
      # This cop is marked as unsafe, because it is possible that this class is a parent
      # for some other subclass, monkey-patched with instance methods or
      # a dummy instance is instantiated from it somewhere.
      #
      # @example
      #   # bad
      #   class SomeClass
      #     def self.some_method
      #       # body omitted
      #     end
      #
      #     def self.some_other_method
      #       # body omitted
      #     end
      #   end
      #
      #   # good
      #   module SomeModule
      #     module_function
      #
      #     def some_method
      #       # body omitted
      #     end
      #
      #     def some_other_method
      #       # body omitted
      #     end
      #   end
      #
      #   # good - has instance method
      #   class SomeClass
      #     def instance_method; end
      #     def self.class_method; end
      #   end
      #
      class StaticClass < Base
        include VisibilityHelp

        MSG = 'Prefer modules to classes with only class methods.'

        def on_class(class_node)
          return if class_node.parent_class

          add_offense(class_node) if class_convertible_to_module?(class_node)
        end

        private

        def class_convertible_to_module?(class_node)
          nodes = class_elements(class_node)
          return false if nodes.empty?

          nodes.all? do |node|
            node_visibility(node) == :public &&
              node.defs_type? ||
              sclass_convertible_to_module?(node) ||
              node.equals_asgn? ||
              extend_call?(node)
          end
        end

        def extend_call?(node)
          node.send_type? && node.method?(:extend)
        end

        def sclass_convertible_to_module?(node)
          return false unless node.sclass_type?

          class_elements(node).all? do |child|
            node_visibility(child) == :public && (child.def_type? || child.equals_asgn?)
          end
        end

        def class_elements(class_node)
          class_def = class_node.body

          if !class_def
            []
          elsif class_def.begin_type?
            class_def.children
          else
            [class_def]
          end
        end
      end
    end
  end
end
