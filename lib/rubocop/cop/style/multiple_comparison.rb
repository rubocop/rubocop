# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks against comparing a variable with multiple items, where
      # `Array#include?` could be used instead to avoid code repetition.
      #
      # @example
      #   # bad
      #   a = 'a'
      #   foo if a == 'a' || a == 'b' || a == 'c'
      #
      #   # good
      #   a = 'a'
      #   foo if ['a', 'b', 'c'].include?(a)
      class MultipleComparison < Cop
        MSG = 'Avoid comparing a variable with multiple items' \
          'in a conditional, use `Array#include?` instead.'.freeze

        def on_if(node)
          return unless nested_variable_comparison?(node.condition)
          add_offense(node, :expression)
        end

        private

        def_node_matcher :simple_double_comparison?, '(send $lvar :== $lvar)'
        def_node_matcher :simple_comparison?, <<-PATTERN
          {(send $lvar :== _)
           (send _ :== $lvar)}
        PATTERN

        def nested_variable_comparison?(node)
          return false unless nested_comparison?(node)
          variables_in_node(node).count == 1
        end

        def variables_in_node(node)
          if node.or_type?
            node.node_parts
                .flat_map { |node_part| variables_in_node(node_part) }
                .uniq
          else
            variables_in_simple_node(node)
          end
        end

        def variables_in_simple_node(node)
          simple_double_comparison?(node) do |var1, var2|
            return [variable_name(var1), variable_name(var2)]
          end
          simple_comparison?(node) do |var|
            return [variable_name(var)]
          end
          []
        end

        def variable_name(node)
          node.children[0]
        end

        def nested_comparison?(node)
          if node.or_type?
            node.node_parts.all? { |node_part| comparison? node_part }
          else
            false
          end
        end

        def comparison?(node)
          simple_comparison?(node) || nested_comparison?(node)
        end
      end
    end
  end
end
