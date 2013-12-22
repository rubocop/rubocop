# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Handles `Max` configuration parameters, especially setting them to an
      # appropriate value with --auto-gen-config.
      module ConfigurableMax
        def max=(value)
          cfg = self.config_to_allow_offences ||= {}
          value = [cfg['Max'], value].max if cfg['Max']
          cfg['Max'] = value
        end
      end
    end
  end
end
