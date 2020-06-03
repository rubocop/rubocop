# frozen_string_literal: true

module RuboCop
  module Cop
    # A group of cops, ready to be called on duty to inspect files.
    # Team is responsible for selecting only relevant cops to be sent on duty,
    # as well as insuring that the needed forces are sent along with them.
    #
    # For performance reasons, Team will first dispatch cops & forces in two groups,
    # first the ones needed for autocorrection (if any), then the rest
    # (unless autocorrections happened).
    class Team
      DEFAULT_OPTIONS = {
        auto_correct: false,
        debug: false
      }.freeze

      Investigation = Struct.new(:offenses, :errors)

      attr_reader :errors, :warnings, :updated_source_file, :cops

      alias updated_source_file? updated_source_file

      def initialize(cops, config = nil, options = nil)
        @cops = cops
        @config = config
        @options = options || DEFAULT_OPTIONS
        @errors = []
        @warnings = []

        validate_config
      end

      # @return [Team]
      def self.new(cop_or_classes, config, options = {})
        # Support v0 api:
        return mobilize(cop_or_classes, config, options) if cop_or_classes.first.is_a?(Class)

        super
      end

      # @return [Team] with cops assembled from the given `cop_classes`
      def self.mobilize(cop_classes, config, options = nil)
        options ||= DEFAULT_OPTIONS
        cops = mobilize_cops(cop_classes, config, options)
        new(cops, config, options)
      end

      # @return [Array<Cop::Cop>]
      def self.mobilize_cops(cop_classes, config, options = nil)
        options ||= DEFAULT_OPTIONS
        only = options.fetch(:only, [])
        safe = options.fetch(:safe, false)
        cop_classes.enabled(config, only, safe).map do |cop_class|
          cop_class.new(config, options)
        end
      end

      def autocorrect?
        @options[:auto_correct]
      end

      def debug?
        @options[:debug]
      end

      def inspect_file(processed_source)
        # If we got any syntax errors, return only the syntax offenses.
        unless processed_source.valid_syntax?
          return Lint::Syntax.offenses_from_processed_source(
            processed_source, @config, @options
          )
        end

        offenses(processed_source)
      end

      def forces
        @forces ||= forces_for(cops)
      end

      def forces_for(cops)
        Force.all.each_with_object([]) do |force_class, forces|
          joining_cops = cops.select { |cop| cop.join_force?(force_class) }
          next if joining_cops.empty?

          forces << force_class.new(joining_cops)
        end
      end

      def autocorrect(buffer, cops)
        @updated_source_file = false
        return unless autocorrect?

        new_source = autocorrect_all_cops(buffer, cops)

        return if new_source == buffer.source

        if @options[:stdin]
          # holds source read in from stdin, when --stdin option is used
          @options[:stdin] = new_source
        else
          filename = buffer.name
          File.open(filename, 'w') { |f| f.write(new_source) }
        end
        @updated_source_file = true
      rescue RuboCop::ErrorWithAnalyzedFileLocation => e
        process_errors(buffer.name, [e])
        raise e.cause
      end

      def external_dependency_checksum
        keys = cops.map(&:external_dependency_checksum).compact
        Digest::SHA1.hexdigest(keys.join)
      end

      private

      def offenses(processed_source) # rubocop:disable Metrics/AbcSize
        # The autocorrection process may have to be repeated multiple times
        # until there are no corrections left to perform
        # To speed things up, run auto-correcting cops by themselves, and only
        # run the other cops when no corrections are left
        on_duty = roundup_relevant_cops(processed_source.file_path)

        autocorrect_cops, other_cops = on_duty.partition(&:autocorrect?)

        autocorrect = investigate(autocorrect_cops, processed_source)

        if autocorrect(processed_source.buffer, autocorrect_cops)
          # We corrected some errors. Another round of inspection will be
          # done, and any other offenses will be caught then, so we don't
          # need to continue.
          return autocorrect.offenses
        end

        other = investigate(other_cops, processed_source)

        errors = [*autocorrect.errors, *other.errors]
        process_errors(processed_source.path, errors)

        autocorrect.offenses.concat(other.offenses)
      end

      def investigate(cops, processed_source)
        return Investigation.new([], {}) if cops.empty?

        commissioner = Commissioner.new(cops, forces_for(cops), @options)
        offenses = commissioner.investigate(processed_source)

        Investigation.new(offenses, commissioner.errors)
      end

      def roundup_relevant_cops(filename)
        cops.reject do |cop|
          cop.excluded_file?(filename) ||
            !support_target_ruby_version?(cop) ||
            !support_target_rails_version?(cop)
        end
      end

      def support_target_ruby_version?(cop)
        return true unless cop.class.respond_to?(:support_target_ruby_version?)

        cop.class.support_target_ruby_version?(cop.target_ruby_version)
      end

      def support_target_rails_version?(cop)
        return true unless cop.class.respond_to?(:support_target_rails_version?)

        cop.class.support_target_rails_version?(cop.target_rails_version)
      end

      def autocorrect_all_cops(buffer, cops)
        corrector = Corrector.new(buffer)

        collate_corrections(corrector, cops)

        if !corrector.corrections.empty?
          corrector.rewrite
        else
          buffer.source
        end
      end

      def collate_corrections(corrector, cops)
        skips = Set.new

        cops.each do |cop|
          next if cop.corrections.empty?
          next if skips.include?(cop.class)

          corrector.corrections.concat(cop.corrections)
          skips.merge(cop.class.autocorrect_incompatible_with)
        end
      end

      def validate_config
        cops.each do |cop|
          cop.validate_config if cop.respond_to?(:validate_config)
        end
      end

      def process_errors(file, errors)
        errors.each do |error|
          line = ":#{error.line}" if error.line
          column = ":#{error.column}" if error.column
          location = "#{file}#{line}#{column}"
          cause = error.cause

          if cause.is_a?(Warning)
            handle_warning(cause, location)
          else
            handle_error(cause, location, error.cop)
          end
        end
      end

      def handle_warning(error, location)
        message = Rainbow("#{error.message} (from file: #{location})").yellow

        @warnings << message
        warn message
        puts error.backtrace if debug?
      end

      def handle_error(error, location, cop)
        message = Rainbow("An error occurred while #{cop.name}" \
                           " cop was inspecting #{location}.").red
        @errors << message
        warn message
        if debug?
          puts error.message, error.backtrace
        else
          warn 'To see the complete backtrace run rubocop -d.'
        end
      end
    end
  end
end
