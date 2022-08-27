# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to allow certain methods when
    # parsing.
    module AllowedMethods
      private

      # @api public
      def allowed_method?(name)
        allowed_methods.include?(name.to_s)
      end

      # @deprecated Use allowed_method? instead
      alias ignored_method? allowed_method?

      # @api public
      def allowed_methods
        if cop_config_deprecated_values.any?(Regexp)
          cop_config_allowed_methods
        else
          cop_config_allowed_methods + cop_config_deprecated_values
        end
      end

      def cop_config_allowed_methods
        @cop_config_allowed_methods ||= Array(cop_config.fetch('AllowedMethods', []))
      end

      def cop_config_deprecated_values
        @cop_config_deprecated_values ||=
          Array(cop_config.fetch('IgnoredMethods', [])) +
          Array(cop_config.fetch('ExcludedMethods', []))
      end
    end
    # @deprecated IgnoredMethods class has been replaced with AllowedMethods.
    IgnoredMethods = AllowedMethods
  end
end
