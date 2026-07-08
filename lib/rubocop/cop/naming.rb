# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `Naming` department. The department's cops are registered for lazy loading
    # and their files are loaded on demand.
    module Naming
      extend LazyLoader

      register_cop :AccessorMethodName, "#{__dir__}/naming/accessor_method_name"
      register_cop :AsciiIdentifiers, "#{__dir__}/naming/ascii_identifiers"
      register_cop :BlockForwarding, "#{__dir__}/naming/block_forwarding"
      register_cop :BlockParameterName, "#{__dir__}/naming/block_parameter_name"
      register_cop :ClassAndModuleCamelCase, "#{__dir__}/naming/class_and_module_camel_case"
      register_cop :ConstantName, "#{__dir__}/naming/constant_name"
      register_cop :FileName, "#{__dir__}/naming/file_name"
      register_cop :HeredocDelimiterCase, "#{__dir__}/naming/heredoc_delimiter_case"
      register_cop :HeredocDelimiterNaming, "#{__dir__}/naming/heredoc_delimiter_naming"
      register_cop :InclusiveLanguage, "#{__dir__}/naming/inclusive_language"
      register_cop :MemoizedInstanceVariableName, "#{__dir__}/naming/memoized_instance_variable_name"
      register_cop :MethodName, "#{__dir__}/naming/method_name"
      register_cop :MethodParameterName, "#{__dir__}/naming/method_parameter_name"
      register_cop :BinaryOperatorParameterName, "#{__dir__}/naming/binary_operator_parameter_name"
      register_cop :PredicateMethod, "#{__dir__}/naming/predicate_method"
      register_cop :PredicatePrefix, "#{__dir__}/naming/predicate_prefix"
      register_cop :RescuedExceptionsVariableName, "#{__dir__}/naming/rescued_exceptions_variable_name"
      register_cop :VariableName, "#{__dir__}/naming/variable_name"
      register_cop :VariableNumber, "#{__dir__}/naming/variable_number"
    end
  end
end
