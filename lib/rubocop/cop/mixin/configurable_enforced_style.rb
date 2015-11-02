# encoding: utf-8

module RuboCop
  module Cop
    # Handles `EnforcedStyle` configuration parameters.
    module ConfigurableEnforcedStyle
      def opposite_style_detected
        style_detected(alternative_style)
      end

      def correct_style_detected
        style_detected(style)
      end

      def style_detected(detected)
        return if no_acceptable_style?
        self.detected_style ||= detected.to_s
        return unless detected_style != detected.to_s
        conflicting_styles_detected
      end

      alias unexpected_style_detected style_detected

      def no_acceptable_style?
        config_to_allow_offenses['Enabled'] == false
      end

      def no_acceptable_style!
        self.config_to_allow_offenses = { 'Enabled' => false }
      end

      def detected_style
        config_to_allow_offenses[parameter_name]
      end

      def detected_style=(style)
        config_to_allow_offenses[parameter_name] = style
      end

      alias_method :conflicting_styles_detected, :no_acceptable_style!
      alias_method :unrecognized_style_detected, :no_acceptable_style!

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
