# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to forbid certain methods when
    # parsing.
    module ForbiddenMethods
      private

      def forbidden_method?(name)
        forbidden_methods.include?(name.to_s)
      end

      def forbidden_methods
        Array(cop_config['ForbiddenMethods']).concat(cop_config_deprecated_values)
      end

      def cop_config_deprecated_values
        []
      end
    end
  end
end
