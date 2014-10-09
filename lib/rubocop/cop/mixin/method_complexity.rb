# encoding: utf-8

module RuboCop
  module Cop
    # This module handles measurement and reporting of complexity in methods.
    module MethodComplexity
      include OnMethod
      include OnDSLMethod
      include ConfigurableMax

      def on_dsl_method(node)
        when_violated_by(node) do |complexity, max|
          name =  "block passed to `#{dsl_method_name(node)}`"
          add_offense(node, :begin, message(name, complexity, max)) do
            self.max = complexity
          end
        end
      end

      private

      def on_method(node, method_name, _args, _body)
        when_violated_by(node) do |complexity, max|
          add_offense(node, :keyword, message(method_name, complexity, max)) do
            self.max = complexity
          end
        end
      end

      def when_violated_by(node)
        max = cop_config['Max']
        complexity = complexity(node)
        yield(complexity, max) if complexity > max
      end

      def complexity(node)
        node.each_node(self.class::COUNTED_NODES).reduce(1) do |score, n|
          score + complexity_score_for(n)
        end
      end

      def message(name, complexity, max)
        format(self.class::MSG, name, complexity, max)
      end
    end
  end
end
