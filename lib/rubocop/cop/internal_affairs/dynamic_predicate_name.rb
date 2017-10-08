# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # This cop makes sure that predicates are dynamically named properly.
      #
      # @example
      #   # bad
      #   def_node_matcher :is_even?(value) ...
      #
      #   # good
      #   def_node_matcher :even?(value)
      #
      #   # bad
      #   def_node_matcher :has_value? ...
      #
      #   # good
      #   def_node_matcher :value? ...
      class DynamicPredicateName < Cop
        include ConfigurablePredicateNaming

        def_node_matcher :def_node_matcher_name, <<-PATTERN
          (send nil? :def_node_matcher
            (sym $_)
            ...)
        PATTERN

        def on_send(node)
          def_node_matcher_name(node) do |method_name|
            predicate_prefixes.each do |prefix|
              next if valid_method_name?(method_name.to_s, prefix)

              add_offense(
                node,
                location: node.first_argument.loc.expression,
                message: message(method_name,
                                 expected_name(method_name.to_s, prefix))
              )
            end
          end
        end

        private

        def cop_config
          @config.for_cop('Naming/PredicateName')
        end
      end
    end
  end
end
