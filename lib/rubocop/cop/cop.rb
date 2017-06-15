# frozen_string_literal: true

require 'uri'

module RuboCop
  module Cop
    # A scaffold for concrete cops.
    #
    # The Cop class is meant to be extended.
    #
    # Cops track offenses and can autocorrect them on the fly.
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
      extend RuboCop::AST::Sexp
      extend NodePattern::Macros
      include RuboCop::AST::Sexp
      include Util
      include IgnoredNode
      include AutocorrectLogic

      attr_reader :config, :offenses, :corrections
      attr_accessor :processed_source # TODO: Bad design.

      @registry = Registry.new

      class << self
        attr_reader :registry
      end

      def self.all
        registry.without_department(:Test).cops
      end

      def self.qualified_cop_name(name, origin)
        registry.qualified_cop_name(name, origin)
      end

      def self.non_rails
        registry.without_department(:Rails)
      end

      def self.inherited(subclass)
        registry.enlist(subclass)
      end

      def self.badge
        @badge ||= Badge.for(name)
      end

      def self.cop_name
        badge.to_s
      end

      def self.department
        badge.department
      end

      def self.lint?
        department == :Lint
      end

      # Returns true if the cop name or the cop namespace matches any of the
      # given names.
      def self.match?(given_names)
        return false unless given_names

        given_names.include?(cop_name) ||
          given_names.include?(department.to_s)
      end

      # List of cops that should not try to autocorrect at the same
      # time as this cop
      #
      # @return [Array<RuboCop::Cop::Cop>]
      #
      # @api public
      def self.autocorrect_incompatible_with
        []
      end

      def initialize(config = nil, options = nil)
        @config = config || Config.new
        @options = options || { debug: false }

        @offenses = []
        @corrections = []
        @processed_source = nil
      end

      def join_force?(_force_class)
        false
      end

      def cop_config
        @cop_config ||= @config.for_cop(self)
      end

      def message(_node = nil)
        self.class::MSG
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      def add_offense(node, loc = :expression, message = nil, severity = nil)
        location = find_location(node, loc)

        return if duplicate_location?(location)

        severity = custom_severity || severity || default_severity

        message ||= message(node)
        message = annotate(message)

        status = enabled_line?(location.line) ? correct(node) : :disabled

        @offenses << Offense.new(severity, location, message, name, status)
        yield if block_given? && status != :disabled
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def find_location(node, loc)
        # Location can be provided as a symbol, e.g.: `:keyword`
        loc.is_a?(Symbol) ? node.loc.public_send(loc) : loc
      end

      def duplicate_location?(location)
        @offenses.any? { |o| o.location == location }
      end

      def correct(node)
        return :unsupported unless support_autocorrect?
        return :uncorrected unless autocorrect?

        correction = autocorrect(node)
        return :uncorrected unless correction
        @corrections << correction
        :corrected
      end

      def config_to_allow_offenses
        Formatter::DisabledConfigFormatter
          .config_to_allow_offenses[cop_name] ||= {}
      end

      def config_to_allow_offenses=(hash)
        Formatter::DisabledConfigFormatter.config_to_allow_offenses[cop_name] =
          hash
      end

      def target_ruby_version
        @config.target_ruby_version
      end

      def target_rails_version
        @config.target_rails_version
      end

      def parse(source, path = nil)
        ProcessedSource.new(source, target_ruby_version, path)
      end

      def cop_name
        @cop_name ||= self.class.cop_name
      end

      alias name cop_name

      def relevant_file?(file)
        file_name_matches_any?(file, 'Include', true) &&
          !file_name_matches_any?(file, 'Exclude', false)
      end

      def excluded_file?(file)
        !relevant_file?(file)
      end

      private

      def annotate(message)
        RuboCop::Cop::MessageAnnotator.new(
          config, cop_config, @options
        ).annotate(message, name)
      end

      def file_name_matches_any?(file, parameter, default_result)
        patterns = cop_config[parameter]
        return default_result unless patterns
        path = nil
        patterns.any? do |pattern|
          # Try to match the absolute path, as Exclude properties are absolute.
          next true if match_path?(pattern, file)

          # Try with relative path.
          path ||= config.path_relative_to_config(file)
          match_path?(pattern, path)
        end
      end

      def enabled_line?(line_number)
        return true unless @processed_source
        @processed_source.comment_config.cop_enabled_at_line?(self, line_number)
      end

      def default_severity
        self.class.lint? ? :warning : :convention
      end

      def custom_severity
        severity = cop_config['Severity']
        return unless severity

        if Severity::NAMES.include?(severity.to_sym)
          severity.to_sym
        else
          message = "Warning: Invalid severity '#{severity}'. " \
            "Valid severities are #{Severity::NAMES.join(', ')}."
          warn(Rainbow(message).red)
        end
      end
    end
  end
end
