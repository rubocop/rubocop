# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Handles `EnforcedStyle` configuration parameters.
      module ConfigurableEnforcedStyle
        def opposite_style_detected
          self.config_to_allow_offences ||=
            { 'EnforcedStyle' => alternative_style.to_s }
          both_styles_detected if config_to_allow_offences['Enabled']
        end

        def correct_style_detected
          # Enabled:true indicates, later when the opposite style is detected,
          # that the correct style is used somewhere.
          self.config_to_allow_offences ||= { 'Enabled' => true }
          both_styles_detected if config_to_allow_offences['EnforcedStyle']
        end

        def both_styles_detected
          # Both correct and opposite styles exist.
          self.config_to_allow_offences = { 'Enabled' => false }
        end

        def unrecognized_style_detected
          # All we can do is to disable.
          self.config_to_allow_offences = { 'Enabled' => false }
        end

        def style
          s = cop_config['EnforcedStyle']
          if cop_config['SupportedStyles'].include?(s)
            s.to_sym
          else
            fail "Unknown style #{s} selected!"
          end
        end

        def alternative_style
          a = cop_config['SupportedStyles'].map(&:to_sym)
          if a.size != 2
            fail 'alternative_style can only be used when there are exactly ' +
              '2 SupportedStyles'
          end
          style == a.first ? a.last : a.first
        end
      end
    end
  end
end
