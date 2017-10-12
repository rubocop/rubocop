# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that predicates are named properly.
      #
      # @example
      #   # bad
      #   def is_even?(value) ...
      #
      #   # good
      #   def even?(value)
      #
      #   # bad
      #   def has_value? ...
      #
      #   # good
      #   def value? ...
      class PredicateName < Cop
        include ConfigurablePredicateNaming

        def on_def(node)
          predicate_prefixes.each do |prefix|
            method_name = node.method_name.to_s

            next if valid_method_name?(method_name, prefix)

            add_offense(
              node,
              location: :name,
              message: message(method_name, expected_name(method_name, prefix))
            )
          end
        end
        alias on_defs on_def
      end
    end
  end
end
