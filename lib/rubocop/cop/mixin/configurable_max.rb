# frozen_string_literal: true

module RuboCop
  module Cop
    # Handles `Max` configuration parameters, especially setting them to an
    # appropriate value with --auto-gen-config.
    module ConfigurableMax
      private

      def max=(value)
        cfg = config_to_allow_offenses
        value = [cfg[max_parameter_name], value].max if cfg[max_parameter_name]
        cfg[max_parameter_name] = value
      end

      def max_parameter_name
        'Max'
      end
    end
  end
end
