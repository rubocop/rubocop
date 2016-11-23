# frozen_string_literal: true

module RuboCop
  module Cop
    # A annotater that takes the basic message from a cop
    # and annotates it for output based on options or settings.
    class OffenseMessageAnnotater
      attr_reader :options, :config, :cop_config

      def initialize(config, cop_config, options)
        @config = config
        @cop_config = cop_config || {}
        @options = options
      end

      def annotate_message(message, name)
        message = "#{name}: #{message}" if display_cop_names?
        message += " #{details}" if extra_details?
        if display_style_guide?
          links = [style_guide_url, reference_url].compact.join(', ')
          message = "#{message} (#{links})"
        end
        message
      end

      def style_guide_url
        url = cop_config['StyleGuide']
        return nil if url.nil? || url.empty?

        base_url = config.for_all_cops['StyleGuideBaseURL']
        return url if base_url.nil? || base_url.empty?

        URI.join(base_url, url).to_s
      end

      private

      def display_style_guide?
        (style_guide_url || reference_url) &&
          (options[:display_style_guide] ||
            config.for_all_cops['DisplayStyleGuide'])
      end

      def reference_url
        url = cop_config['Reference']
        url.nil? || url.empty? ? nil : url
      end

      def extra_details?
        options[:extra_details] || config.for_all_cops['ExtraDetails']
      end

      def debug?
        options[:debug]
      end

      def display_cop_names?
        debug? || options[:display_cop_names] ||
          config.for_all_cops['DisplayCopNames']
      end

      def details
        details = cop_config && cop_config['Details']
        details.nil? || details.empty? ? nil : details
      end
    end
  end
end
