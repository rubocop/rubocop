# frozen_string_literal: true

module RuboCop
  module Cop
    # Helpers for builtin documentation
    module Documentation
      module_function

      # @api private
      def department_to_basename(department)
        "cops_#{department.downcase}"
      end

      # @api private
      def url_for(cop_class)
        base = department_to_basename(cop_class.department)
        fragment = cop_class.cop_name.downcase.gsub(/[^a-z]/, '')
        "https://docs.rubocop.org/rubocop/#{base}.html##{fragment}"
      end
    end
  end
end
