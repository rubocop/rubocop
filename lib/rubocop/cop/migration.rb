# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `Migration` department. The department's cops are registered for lazy loading
    # and their files are loaded on demand.
    module Migration
      extend LazyLoader

      register_cop :DepartmentName, "#{__dir__}/migration/department_name"
    end
  end
end
