# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Check that methods are defined alphabetically.
      #
      # @example
      #   # bad
      #   def self.b; end
      #   def self.a; end
      #
      #   def b; end
      #   def a; end
      #
      #   private
      #
      #   def d; end
      #   def c; end
      #
      #   # good
      #   def self.a; end
      #   def self.b; end
      #
      #   def a; end
      #   def b; end
      #
      #   private
      #
      #   def c; end
      #   def d; end
      class OrderedMethods < Cop
        include IgnoredMethods
        include RangeHelp

        MSG = 'Methods should be sorted alphabetically.'.freeze
        VISIBILITY_MODIFIERS = %i[
          module_function
          private
          protected
          public
        ].freeze

        def_node_matcher :class_def?, 'defs'
        def_node_matcher :instance_def?, 'def'
        def_node_matcher :visibility_modifier?, <<-PATTERN
          (send nil? { #{VISIBILITY_MODIFIERS.map(&:inspect).join(' ')} })
        PATTERN

        def on_begin(node)
          consecutive_methods(node.children) do |previous, current|
            add_offense(current) unless ordered?(previous, current)
          end
        end

        private

        def consecutive_methods(ast)
          filtered_and_grouped(ast).each do |method_group|
            method_group.each_cons(2) do |left_method, right_method|
              yield left_method, right_method
            end
          end
        end

        def filter_relevant_nodes(nodes)
          nodes.select do |node|
            (
              class_def?(node) ||
                instance_def?(node) ||
                visibility_modifier?(node)
            ) && !ignored_method?(node.method_name)
          end
        end

        def filtered_and_grouped(ast)
          group_methods_by_visiblity_block(filter_relevant_nodes(ast))
        end

        # Group methods by the visiblity block they are declared in. Multiple
        # blocks of the same visiblity will have their methods grouped
        # separately; for example, the following would be separated into two
        # groups:
        #   private
        #   def a; end
        #   private
        #   def b; end
        def group_methods_by_visiblity_block(nodes)
          is_class_method_block = false
          nodes.each_with_object([[]]) do |node, grouped_methods|
            if new_visiblity_block?(node, is_class_method_block)
              grouped_methods << []
            end

            is_class_method_block = true if class_def?(node)
            is_class_method_block = false if instance_def?(node)

            if visibility_modifier?(node)
              is_class_method_block = false
              next
            end

            grouped_methods.last << node
          end
        end

        def new_visiblity_block?(node, is_class_method_block)
          (class_def?(node) && !is_class_method_block) ||
            (instance_def?(node) && is_class_method_block) ||
            visibility_modifier?(node)
        end

        def ordered?(left_method, right_method)
          (left_method.method_name <=> right_method.method_name) != 1
        end
      end
    end
  end
end
