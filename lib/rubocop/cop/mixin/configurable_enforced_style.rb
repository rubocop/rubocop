# frozen_string_literal: true

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

      def unexpected_style_detected(unexpected)
        style_detected(unexpected)
      end

      def ambiguous_style_detected(*possibilities)
        style_detected(possibilities)
      end

      def style_detected(detected)
        return if no_acceptable_style?

        # `detected` can be a single style, or an Array of possible styles
        # (if there is more than one which matches the observed code)
        detected_as_strings = Array(detected).map(&:to_s)

        if !detected_style # we haven't observed any specific style yet
          self.detected_style = detected_as_strings
        elsif detected_style.is_a?(Array)
          self.detected_style &= detected_as_strings
        elsif !detected.include?(detected_style)
          no_acceptable_style!
        end
      end

      def no_acceptable_style?
        config_to_allow_offenses['Enabled'] == false
      end

      def no_acceptable_style!
        self.config_to_allow_offenses = { 'Enabled' => false }
        Formatter::DisabledConfigFormatter.detected_styles[cop_name] = []
      end

      def detected_style
        Formatter::DisabledConfigFormatter.detected_styles[cop_name] ||= nil
      end

      def detected_style=(style)
        Formatter::DisabledConfigFormatter.detected_styles[cop_name] = style

        return no_acceptable_style! if style.nil?
        return no_acceptable_style! if style.empty?

        config_to_allow_offenses[style_parameter_name] = style.first
      end

      alias conflicting_styles_detected no_acceptable_style!
      alias unrecognized_style_detected no_acceptable_style!

      def style
        @enforced_style ||= begin
          s = cop_config[style_parameter_name].to_sym
          unless supported_styles.include?(s)
            raise "Unknown style #{s} selected!"
          end
          s
        end
      end

      def alternative_style
        if supported_styles.size != 2
          raise 'alternative_style can only be used when there are exactly ' \
               '2 SupportedStyles'
        end
        (supported_styles - [style]).first
      end

      def supported_styles
        @supported_styles ||= begin
          supported_styles = Util.to_supported_styles(style_parameter_name)
          cop_config[supported_styles].map(&:to_sym)
        end
      end

      def style_parameter_name
        'EnforcedStyle'
      end
    end
  end
end
