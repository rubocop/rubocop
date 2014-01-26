# encoding: utf-8

module Rubocop
  module Cop
    class CorrectionNotPossible < Exception; end

    # Store for all cops with helper functions
    class CopStore < ::Array
      # @return [Array<String>] list of types for current cops.
      def types
        @types = map(&:cop_type).uniq! unless defined? @types
        @types
      end

      # @return [Array<Cop>] Cops for that specific type.
      def with_type(type)
        select { |c| c.cop_type == type }
      end

      # @return [Array<Cop>] Cops not for a specific type.
      def without_type(type)
        reject { |c| c.cop_type == type }
      end
    end

    # A scaffold for concrete cops.
    #
    # The Cop class is meant to be extended.
    #
    # Cops track offences and can autocorrect them of the fly.
    #
    # A commissioner object is responsible for traversing the AST and invoking
    # the specific callbacks on each cop.
    # If a cop needs to do its own processing of the AST or depends on
    # something else, it should define the `#investigate` method and do
    # the processing there.
    #
    # @example
    #
    #   class CustomCop < Cop
    #     def investigate(processed_source)
    #       # Do custom processing
    #     end
    #   end
    class Cop
      extend AST::Sexp
      include Util
      include IgnoredNode

      attr_reader :config, :offences, :corrections
      attr_accessor :processed_source # TODO: Bad design.

      @all = CopStore.new

      def self.all
        @all.clone
      end

      def self.non_rails
        @all.without_type(:rails)
      end

      def self.inherited(subclass)
        @all << subclass
      end

      def self.cop_name
        name.to_s.split('::').last
      end

      def self.cop_type
        name.to_s.split('::')[-2].downcase.to_sym
      end

      def self.lint?
        cop_type == :lint
      end

      def self.rails?
        cop_type == :rails
      end

      def initialize(config = nil, options = nil)
        @config = config || Config.new
        @options = options || { auto_correct: false, debug: false }

        @offences = []
        @corrections = []
      end

      def cop_config
        @config.for_cop(self)
      end

      def autocorrect?
        @options[:auto_correct] && support_autocorrect?
      end

      def debug?
        @options[:debug]
      end

      def display_cop_names?
        debug? || @options[:display_cop_names]
      end

      def message(node = nil)
        self.class::MSG
      end

      def support_autocorrect?
        respond_to?(:autocorrect, true)
      end

      def add_offence(node, loc, message = nil, severity = nil)
        location = loc.is_a?(Symbol) ? node.loc.send(loc) : loc

        return if disabled_line?(location.line)

        severity = custom_severity || severity || default_severity

        message = message ? message : message(node)
        message = display_cop_names? ? "#{name}: #{message}" : message

        corrected = begin
                      autocorrect(node) if autocorrect?
                      autocorrect?
                    rescue CorrectionNotPossible
                      false
                    end
        @offences << Offence.new(severity, location, message, name, corrected)
        yield if block_given?
      end

      def config_to_allow_offences
        Formatter::DisabledConfigFormatter.config_to_allow_offences[cop_name]
      end

      def config_to_allow_offences=(hash)
        Formatter::DisabledConfigFormatter.config_to_allow_offences[cop_name] =
          hash
      end

      def cop_name
        self.class.cop_name
      end

      alias_method :name, :cop_name

      def include_file?(file)
        buffer_name_matches_any?('Include', true)
      end

      def exclude_file?(file)
        buffer_name_matches_any?('Exclude', false)
      end

      def relevant_file?(file)
        include_file?(file) && !exclude_file?(file)
      end

      private

      def buffer_name_matches_any?(parameter, default_result)
        patterns = cop_config && cop_config[parameter]
        return default_result unless patterns
        path = relative_path(processed_source.buffer.name)
        patterns.any? { |pattern| match_path?(pattern, path) }
      end

      def disabled_line?(line_number)
        return false unless @processed_source
        disabled_lines = @processed_source.disabled_lines_for_cops[name]
        return false unless disabled_lines
        disabled_lines.include?(line_number)
      end

      def default_severity
        self.class.lint? ? :warning : :convention
      end

      def custom_severity
        severity = cop_config && cop_config['Severity']
        if severity
          if Offence::SEVERITIES.include?(severity.to_sym)
            severity.to_sym
          else
            warn "Warning: Invalid severity '#{severity}'. " +
                 "Valid severities are #{Offence::SEVERITIES.join(', ')}."
                 .color(:red)
          end
        end
      end
    end
  end
end
