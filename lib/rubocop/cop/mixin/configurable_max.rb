# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Handles `Max` configuration parameters, especially setting them to an
    # appropriate value with --auto-gen-config.
    module ConfigurableMax
      def max=(value)
        cfg = config_to_allow_offenses
        value = [cfg[parameter_name], value].max if cfg[parameter_name]
        cfg[parameter_name] = value
      end

      def parameter_name
        'Max'
      end
    end
  end
end
