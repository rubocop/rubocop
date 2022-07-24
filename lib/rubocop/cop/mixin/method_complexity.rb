# frozen_string_literal: true

module RuboCop
  module Cop
    # @api private
    #
    # This module handles measurement and reporting of complexity in methods.
    module MethodComplexity
      include AllowedMethods
      include AllowedPattern
      include Metrics::Utils::RepeatedCsendDiscount
      extend NodePattern::Macros
      extend ExcludeLimit

      exclude_limit 'Max'

      def on_def(node)
        return if allowed_method?(node.method_name) || matches_allowed_pattern?(node.method_name)

        check_complexity(node, node.method_name)
      end
      alias on_defs on_def

      def on_block(node)
        define_method?(node) do |name|
          return if allowed_method?(name) || matches_allowed_pattern?(name)

          check_complexity(node, name)
        end
      end

      private

      # @!method define_method?(node)
      def_node_matcher :define_method?, <<~PATTERN
        (block
         (send nil? :define_method ({sym str} $_))
         args
         _)
      PATTERN

      def check_complexity(node, method_name)
        # Accepts empty methods always.
        return unless node.body

        max = cop_config['Max']
        reset_repeated_csend
        complexity, abc_vector = complexity(node.body)

        return unless complexity > max

        msg = format(self.class::MSG,
                     method: method_name,
                     complexity: complexity,
                     abc_vector: abc_vector,
                     max: max)

        add_offense(node, message: msg) { self.max = complexity.ceil }
      end

      def complexity(body)
        body.each_node(:lvasgn, *self.class::COUNTED_NODES).reduce(1) do |score, node|
          if node.lvasgn_type?
            reset_on_lvasgn(node)
            next score
          end
          score + complexity_score_for(node)
        end
      end
    end
  end
end
