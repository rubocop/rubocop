# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `Security` department. The department's cops are registered for lazy loading
    # and their files are loaded on demand.
    module Security
      extend LazyLoader

      register_cop :CompoundHash, "#{__dir__}/security/compound_hash"
      register_cop :Eval, "#{__dir__}/security/eval"
      register_cop :IoMethods, "#{__dir__}/security/io_methods"
      register_cop :JSONLoad, "#{__dir__}/security/json_load"
      register_cop :MarshalLoad, "#{__dir__}/security/marshal_load"
      register_cop :Open, "#{__dir__}/security/open"
      register_cop :YAMLLoad, "#{__dir__}/security/yaml_load"
    end
  end
end
