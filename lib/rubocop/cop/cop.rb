# encoding: utf-8

module RuboCop
  module Cop
    class CorrectionNotPossible < Exception; end
    class AmbiguousCopName < Exception; end

    # Store for all cops with helper functions
    class CopStore < ::Array
      # @return [Array<String>] list of types for current cops.
      def types
        @types = map(&:cop_type).uniq! unless defined? @types
        @types
      end

      # @return [Array<Cop>] Cops for that specific type.
      def with_type(type)
        CopStore.new(select { |c| c.cop_type == type })
      end

      # @return [Array<Cop>] Cops not for a specific type.
      def without_type(type)
        CopStore.new(reject { |c| c.cop_type == type })
      end
    end

    # A scaffold for concrete cops.
    #
    # The Cop class is meant to be extended.
    #
    # Cops track offenses and can autocorrect them of the fly.
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

      attr_reader :config, :offenses, :corrections
      attr_accessor :processed_source # TODO: Bad design.

      @all = CopStore.new

      def self.all
        @all.without_type(:test)
      end

      def self.qualified_cop_name(name, origin)
        @cop_names ||= Set.new(all.map(&:cop_name))
        basename = File.basename(name)
        found_ns = @all.types.map(&:capitalize).select do |ns|
          @cop_names.include?("#{ns}/#{basename}")
        end

        case found_ns.size
        when 0 then name # No namespace found. Deal with it later in caller.
        when 1 then cop_name_with_namespace(name, origin, basename, found_ns[0])
        else fail AmbiguousCopName, "`#{basename}` used in #{origin}"
        end
      end

      def self.cop_name_with_namespace(name, origin, basename, found_ns)
        if name != basename && found_ns != File.dirname(name).to_sym
          warn "#{origin}: #{name} has the wrong namespace - should be " \
               "#{found_ns}"
        end
        "#{found_ns}/#{basename}"
      end

      def self.non_rails
        all.without_type(:rails)
      end

      def self.inherited(subclass)
        @all << subclass
      end

      def self.cop_name
        @cop_name ||= name.to_s.split('::').last(2).join('/')
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

        @offenses = []
        @corrections = []
      end

      def join_force?(_force_class)
        false
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
        debug? || @options[:display_cop_names] ||
          config['AllCops'] && config['AllCops']['DisplayCopNames']
      end

      def message(_node = nil)
        self.class::MSG
      end

      def support_autocorrect?
        respond_to?(:autocorrect, true)
      end

      def add_offense(node, loc, message = nil, severity = nil)
        location = loc.is_a?(Symbol) ? node.loc.send(loc) : loc

        return unless enabled_line?(location.line)

        # Don't include the same location twice for one cop.
        return if @offenses.find { |o| o.location == location }

        severity = custom_severity || severity || default_severity

        message ||= message(node)
        message = display_cop_names? ? "#{name}: #{message}" : message

        corrected = begin
                      autocorrect(node) if autocorrect?
                      autocorrect?
                    rescue CorrectionNotPossible
                      false
                    end
        @offenses << Offense.new(severity, location, message, name, corrected)
        yield if block_given?
      end

      def config_to_allow_offenses
        Formatter::DisabledConfigFormatter.config_to_allow_offenses[cop_name]
      end

      def config_to_allow_offenses=(hash)
        Formatter::DisabledConfigFormatter.config_to_allow_offenses[cop_name] =
          hash
      end

      def cop_name
        self.class.cop_name
      end

      alias_method :name, :cop_name

      def relevant_file?(file)
        file_name_matches_any?(file, 'Include', true) &&
          !file_name_matches_any?(file, 'Exclude', false)
      end

      private

      def file_name_matches_any?(file, parameter, default_result)
        patterns = cop_config && cop_config[parameter]
        return default_result unless patterns
        path = nil
        patterns.any? do |pattern|
          # Try to match the absolute path, as Exclude properties are absolute.
          next true if match_path?(pattern, file, config.loaded_path)

          # Try with relative path.
          path ||= config.path_relative_to_config(file)
          match_path?(pattern, path, config.loaded_path)
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
        severity = cop_config && cop_config['Severity']
        return unless severity

        if Severity::NAMES.include?(severity.to_sym)
          severity.to_sym
        else
          warn("Warning: Invalid severity '#{severity}'. " +
               "Valid severities are #{Severity::NAMES.join(', ')}."
               .color(:red))
        end
      end
    end
  end
end
