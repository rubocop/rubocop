# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the Migration department
    module Migration
      extend CopLazyLoader

      register_cop :DepartmentName, 'rubocop/cop/migration/department_name'
    end
  end
end
