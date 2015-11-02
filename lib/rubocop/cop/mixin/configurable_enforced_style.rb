# encoding: utf-8

module RuboCop
  module Cop
    # Handles `EnforcedStyle` configuration parameters.
    module ConfigurableEnforcedStyle
      def unexpected_style_detected(style)
        return if config_to_allow_offenses['Enabled'] == false
        config_to_allow_offenses[parameter_name] ||= style.to_s
        return unless config_to_allow_offenses['Enabled'] ||
                      config_to_allow_offenses[parameter_name] != style.to_s
        conflicting_styles_detected
      end

      def opposite_style_detected
        unexpected_style_detected(alternative_style)
      end

      def correct_style_detected
        # Enabled:true indicates, later when the opposite style is detected,
        # that the correct style is used somewhere.
        config_to_allow_offenses['Enabled'] ||= true
        conflicting_styles_detected if config_to_allow_offenses[parameter_name]
      end

      def conflicting_styles_detected
        self.config_to_allow_offenses = { 'Enabled' => false }
      end

      def unrecognized_style_detected
        # All we can do is to disable.
        self.config_to_allow_offenses = { 'Enabled' => false }
      end

      def style
        s = cop_config[parameter_name]
        if cop_config['SupportedStyles'].include?(s)
          s.to_sym
        else
          fail "Unknown style #{s} selected!"
        end
      end

      def alternative_style
        a = cop_config['SupportedStyles'].map(&:to_sym)
        if a.size != 2
          fail 'alternative_style can only be used when there are exactly ' \
               '2 SupportedStyles'
        end
        style == a.first ? a.last : a.first
      end

      def parameter_name
        'EnforcedStyle'
      end
    end
  end
end
