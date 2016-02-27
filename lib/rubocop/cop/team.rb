# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # FIXME
    class Team
      # If these cops try to autocorrect the same file at the same time,
      # bad things are liable to happen
      INCOMPATIBLE_COPS = {
        Style::SymbolProc => [Style::SpaceBeforeBlockBraces],
        Style::SpaceBeforeBlockBraces => [Style::SymbolProc]
      }.freeze

      DEFAULT_OPTIONS = {
        auto_correct: false,
        debug: false
      }.freeze

      attr_reader :errors, :warnings, :updated_source_file

      alias updated_source_file? updated_source_file

      def initialize(cop_classes, config, options = nil)
        @cop_classes = cop_classes
        @config = config
        @options = options || DEFAULT_OPTIONS
        @errors = []
        @warnings = []

        validate_config
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
          return Lint::Syntax.offenses_from_processed_source(processed_source)
        end

        # The autocorrection process may have to be repeated multiple times
        # until there are no corrections left to perform
        # To speed things up, run auto-correcting cops by themselves, and only
        # run the other cops when no corrections are left
        autocorrect_cops, other_cops = cops.partition(&:autocorrect?)
        offenses = []
        errors = {}

        if autocorrect_cops.any?
          commissioner = Commissioner.new(autocorrect_cops,
                                          forces_for(autocorrect_cops))
          offenses = commissioner.investigate(processed_source)
          if autocorrect(processed_source.buffer, autocorrect_cops)
            # We corrected some errors. Another round of inspection will be
            # done, and any other offenses will be caught then, so we don't
            # need to continue.
            return offenses
          end
          errors = commissioner.errors
        end

        commissioner = Commissioner.new(other_cops, forces_for(other_cops))
        offenses.concat(commissioner.investigate(processed_source))
        errors.merge!(commissioner.errors)
        process_commissioner_errors(processed_source.path, errors)
        offenses
      end

      def cops
        @cops ||= @cop_classes.select { |c| cop_enabled?(c) }.map do |cop_class|
          cop_class.new(@config, @options)
        end
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

      private

      def cop_enabled?(cop_class)
        @config.cop_enabled?(cop_class) ||
          (@options[:only] || []).include?(cop_class.cop_name)
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
          File.open(filename, 'wb') { |f| f.write(new_source) }
        end
        @updated_source_file = true
      end

      def autocorrect_all_cops(buffer, cops)
        corrector = Corrector.new(buffer)
        skip = Set.new

        cops.each do |cop|
          next if cop.corrections.empty?
          next if skip.include?(cop.class)
          corrector.corrections.concat(cop.corrections)
          incompatible = INCOMPATIBLE_COPS[cop.class]
          skip.merge(incompatible) if incompatible
        end

        if !corrector.corrections.empty?
          corrector.rewrite
        else
          buffer.source
        end
      end

      def validate_config
        cops.each do |cop|
          cop.validate_config if cop.respond_to?(:validate_config)
        end
      end

      def process_commissioner_errors(file, file_errors)
        file_errors.each do |cop, errors|
          errors.each do |e|
            if e.is_a?(Warning)
              handle_warning(e,
                             Rainbow("#{e.message} (from file: " \
                             "#{file})").yellow)
            else
              handle_error(e,
                           Rainbow("An error occurred while #{cop.name}" \
                           " cop was inspecting #{file}.").red)
            end
          end
        end
      end

      def handle_warning(e, message)
        @warnings << message
        warn message
        puts e.backtrace if debug?
      end

      def handle_error(e, message)
        @errors << message
        warn message
        if debug?
          puts e.message, e.backtrace
        else
          warn 'To see the complete backtrace run rubocop -d.'
        end
      end
    end
  end
end
