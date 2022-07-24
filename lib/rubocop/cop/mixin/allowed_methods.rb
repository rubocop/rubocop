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
        deprecated_values = cop_config_deprecated_values
        if deprecated_values.any?(Regexp)
          cop_config.fetch('AllowedMethods', [])
        else
          Array(cop_config['AllowedMethods']).concat(deprecated_values)
        end
      end

      def cop_config_deprecated_values
        Array(cop_config['IgnoredMethods']).concat(Array(cop_config['ExcludedMethods']))
      end
    end
    # @deprecated IgnoredMethods class has been replaced with AllowedMethods.
    IgnoredMethods = AllowedMethods
  end
end
