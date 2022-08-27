# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for the presence of constructors and lifecycle callbacks
      # without calls to `super`.
      #
      # This cop does not consider `method_missing` (and `respond_to_missing?`)
      # because in some cases it makes sense to overtake what is considered a
      # missing method. In other cases, the theoretical ideal handling could be
      # challenging or verbose for no actual gain.
      #
      # @example
      #   # bad
      #   class Employee < Person
      #     def initialize(name, salary)
      #       @salary = salary
      #     end
      #   end
      #
      #   # good
      #   class Employee < Person
      #     def initialize(name, salary)
      #       super(name)
      #       @salary = salary
      #     end
      #   end
      #
      #   # bad
      #   class Parent
      #     def self.inherited(base)
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   class Parent
      #     def self.inherited(base)
      #       super
      #       do_something
      #     end
      #   end
      #
      class MissingSuper < Base
        CONSTRUCTOR_MSG = 'Call `super` to initialize state of the parent class.'
        CALLBACK_MSG    = 'Call `super` to invoke callback defined in the parent class.'

        STATELESS_CLASSES = %w[BasicObject Object].freeze

        CLASS_LIFECYCLE_CALLBACKS   = %i[inherited].freeze
        METHOD_LIFECYCLE_CALLBACKS  = %i[method_added method_removed method_undefined
                                         singleton_method_added singleton_method_removed
                                         singleton_method_undefined].freeze

        CALLBACKS = (CLASS_LIFECYCLE_CALLBACKS + METHOD_LIFECYCLE_CALLBACKS).to_set.freeze

        def on_def(node)
          return unless offender?(node)

          if node.method?(:initialize) && inside_class_with_stateful_parent?(node)
            add_offense(node, message: CONSTRUCTOR_MSG)
          elsif callback_method_def?(node)
            add_offense(node, message: CALLBACK_MSG)
          end
        end

        def on_defs(node)
          return if !callback_method_def?(node) || contains_super?(node)

          add_offense(node, message: CALLBACK_MSG)
        end

        private

        def offender?(node)
          (node.method?(:initialize) || callback_method_def?(node)) && !contains_super?(node)
        end

        def callback_method_def?(node)
          return unless CALLBACKS.include?(node.method_name)

          node.each_ancestor(:class, :sclass, :module).first
        end

        def contains_super?(node)
          node.each_descendant(:super, :zsuper).any?
        end

        def inside_class_with_stateful_parent?(node)
          class_node = node.each_ancestor(:class).first
          class_node&.parent_class && !stateless_class?(class_node.parent_class)
        end

        def stateless_class?(node)
          STATELESS_CLASSES.include?(node.const_name)
        end
      end
    end
  end
end
