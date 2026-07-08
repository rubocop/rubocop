# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `Metrics` department. The department's cops are registered for lazy loading
    # and their files are loaded on demand.
    module Metrics
      extend LazyLoader

      register_cop :CyclomaticComplexity, "#{__dir__}/metrics/cyclomatic_complexity"
      register_cop :AbcSize, "#{__dir__}/metrics/abc_size"
      register_cop :BlockLength, "#{__dir__}/metrics/block_length"
      register_cop :BlockNesting, "#{__dir__}/metrics/block_nesting"
      register_cop :ClassLength, "#{__dir__}/metrics/class_length"
      register_cop :CollectionLiteralLength, "#{__dir__}/metrics/collection_literal_length"
      register_cop :MethodLength, "#{__dir__}/metrics/method_length"
      register_cop :ModuleLength, "#{__dir__}/metrics/module_length"
      register_cop :ParameterLists, "#{__dir__}/metrics/parameter_lists"
      register_cop :PerceivedComplexity, "#{__dir__}/metrics/perceived_complexity"

      # Utility classes for `Metrics` department cops.
      module Utils
        autoload :AbcSizeCalculator, "#{__dir__}/metrics/utils/abc_size_calculator"
        autoload :CodeLengthCalculator, "#{__dir__}/metrics/utils/code_length_calculator"
        autoload :IteratingBlock, "#{__dir__}/metrics/utils/iterating_block"
        autoload :RepeatedAttributeDiscount, "#{__dir__}/metrics/utils/repeated_attribute_discount"
        autoload :RepeatedCsendDiscount, "#{__dir__}/metrics/utils/repeated_csend_discount"
      end
    end
  end
end
