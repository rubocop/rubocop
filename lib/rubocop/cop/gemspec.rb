# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `Gemspec` department. The department's cops are registered for lazy loading
    # and their files are loaded on demand.
    module Gemspec
      extend LazyLoader

      register_cop :AddRuntimeDependency, "#{__dir__}/gemspec/add_runtime_dependency"
      register_cop :AttributeAssignment, "#{__dir__}/gemspec/attribute_assignment"
      register_cop :DependencyVersion, "#{__dir__}/gemspec/dependency_version"
      register_cop :DeprecatedAttributeAssignment, "#{__dir__}/gemspec/deprecated_attribute_assignment"
      register_cop :DevelopmentDependencies, "#{__dir__}/gemspec/development_dependencies"
      register_cop :DuplicatedAssignment, "#{__dir__}/gemspec/duplicated_assignment"
      register_cop :OrderedDependencies, "#{__dir__}/gemspec/ordered_dependencies"
      register_cop :RequireMFA, "#{__dir__}/gemspec/require_mfa"
      register_cop :RequiredRubyVersion, "#{__dir__}/gemspec/required_ruby_version"
      register_cop :RubyVersionGlobalsUsage, "#{__dir__}/gemspec/ruby_version_globals_usage"
    end
  end
end
