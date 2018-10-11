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

        # `detected` can be a single style or an Array of possible styles
        # (if there is more than one which matches the observed code)
        detected_as_strings = Array(detected).map(&:to_s)

        updated_list = if detected_style
                         detected_style & detected_as_strings
                       else
                         # We haven't observed any specific style yet.
                         detected_as_strings
                       end
        if updated_list.empty?
          no_acceptable_style!
        else
          self.detected_style = updated_list
          config_to_allow_offenses[style_parameter_name] = updated_list.first
        end
      end

      def no_acceptable_style?
        config_to_allow_offenses['Enabled'] == false
      end

      def no_acceptable_style!
        self.config_to_allow_offenses = { 'Enabled' => false }
      end

      def detected_style
        Formatter::DisabledConfigFormatter.detected_styles[cop_name] ||= nil
      end

      def detected_style=(style)
        Formatter::DisabledConfigFormatter.detected_styles[cop_name] = style
      end

      alias conflicting_styles_detected no_acceptable_style!
      alias unrecognized_style_detected no_acceptable_style!

      def style
        @style ||= begin
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
        alternative_styles.first
      end

      def alternative_styles
        (supported_styles - [style])
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
