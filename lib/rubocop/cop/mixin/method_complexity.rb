# frozen_string_literal: true

module RuboCop
  module Cop
    # This module handles measurement and reporting of complexity in methods.
    module MethodComplexity
      include ConfigurableMax
      extend NodePattern::Macros

      def on_def(node)
        check_complexity(node, node.method_name)
      end
      alias on_defs on_def

      def on_block(node)
        define_method?(node) do |name|
          check_complexity(node, name)
        end
      end

      private

      def_node_matcher :define_method?, <<-PATTERN
        (block
         (send nil? :define_method ({sym str} $_))
         args
         _)
      PATTERN

      def check_complexity(node, method_name)
        # Accepts empty methods always.
        return unless node.body

        max = cop_config['Max']
        complexity = complexity(node.body)

        return unless complexity > max

        msg = format(self.class::MSG,
                     method: method_name,
                     complexity: complexity,
                     max: max)

        add_offense(node, message: msg) do
          self.max = complexity.ceil
        end
      end

      def complexity(body)
        body.each_node(*self.class::COUNTED_NODES).reduce(1) do |score, n|
          score + complexity_score_for(n)
        end
      end
    end
  end
end
