# frozen_string_literal: true

module RuboCop
  module Cop
    # Common code for cops that deal with preferred methods.
    module MethodPreference
      private

      def default_cop_config
        ConfigLoader.default_configuration[cop_name]
      end

      def preferred_method(method)
        preferred_methods[method.to_sym]
      end

      def preferred_methods
        @preferred_methods ||=
          begin
            # Make sure default configuration 'foo' => 'bar' is removed from
            # the total configuration if there is a 'bar' => 'foo' override.
            default = default_cop_config['PreferredMethods']
            merged = cop_config['PreferredMethods']
            overrides = merged.values - default.values
            merged.reject { |key, _| overrides.include?(key) }.symbolize_keys
          end
      end
    end
  end
end
