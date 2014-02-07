# encoding: utf-8

module Rubocop
  module Cop
    # Handles `Message` configuration parameters.
    module ConfigurableMessage
      def message=(value)
        cfg = self.config_to_allow_offences ||= {}
        cfg[parameter_name] = value
      end

      def parameter_name
        'Message'
      end
    end
  end
end
