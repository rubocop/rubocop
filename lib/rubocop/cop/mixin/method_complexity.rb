# frozen_string_literal: true

module RuboCop
  module Cop
    # This module handles measurement and reporting of complexity in methods.
    module MethodComplexity
      include ConfigurableMax

      def on_def(node)
        max = cop_config['Max']
        complexity = complexity(node)

        return unless complexity > max

        msg = format(self.class::MSG, node.method_name, complexity, max)

        add_offense(node, message: msg) do
          self.max = complexity.ceil
        end
      end
      alias on_defs on_def

      private

      def complexity(node)
        node.each_node(*self.class::COUNTED_NODES).reduce(1) do |score, n|
          score + complexity_score_for(n)
        end
      end
    end
  end
end
