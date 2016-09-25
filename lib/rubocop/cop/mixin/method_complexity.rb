# frozen_string_literal: true

module RuboCop
  module Cop
    # This module handles measurement and reporting of complexity in methods.
    module MethodComplexity
      include OnMethodDef
      include ConfigurableMax

      private

      def on_method_def(node, method_name, _args, _body)
        max = cop_config['Max']
        complexity = complexity(node)
        return unless complexity > max

        add_offense(node, :keyword,
                    format(self.class::MSG, method_name, complexity, max)) do
          self.max = complexity.ceil
        end
      end

      def complexity(node)
        node.each_node(*self.class::COUNTED_NODES).reduce(1) do |score, n|
          score + complexity_score_for(n)
        end
      end
    end
  end
end
