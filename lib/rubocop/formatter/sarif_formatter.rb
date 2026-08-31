# frozen_string_literal: true

require 'digest'

module RuboCop
  module Formatter
    # This formatter formats the report data in SARIF 2.1.0, the OASIS standard
    # for static analysis results. It's understood by GitHub code scanning,
    # Azure DevOps, and other tools that aggregate analyzer output.
    #
    # SARIF only knows three severity levels, so RuboCop's `info`, `refactor`
    # and `convention` severities are all reported as `note`.
    class SARIFFormatter < BaseFormatter
      SCHEMA_URI = 'https://json.schemastore.org/sarif-2.1.0.json'
      SARIF_VERSION = '2.1.0'
      INFORMATION_URI = 'https://rubocop.org'

      SEVERITY_LEVELS = {
        info: 'note',
        refactor: 'note',
        convention: 'note',
        warning: 'warning',
        error: 'error',
        fatal: 'error'
      }.freeze

      def initialize(output, options = {})
        super

        @rules = []
        @rule_indexes = {}
        @results = []
        @config_store = nil
      end

      def file_started(_file, options)
        @config_store = options[:config_store]
      end

      def file_finished(file, offenses)
        offenses.each do |offense|
          @results << result_for(file, offense)
        end
      end

      def finished(_inspected_files)
        output.write(report.to_json)
      end

      private

      def report
        {
          '$schema': SCHEMA_URI,
          version: SARIF_VERSION,
          runs: [{ tool: { driver: driver }, results: @results }]
        }
      end

      def driver
        {
          name: 'RuboCop',
          version: RuboCop::Version::STRING,
          semanticVersion: RuboCop::Version::STRING,
          informationUri: INFORMATION_URI,
          rules: @rules
        }
      end

      def result_for(file, offense)
        result = {
          ruleId: offense.cop_name,
          ruleIndex: rule_index_for(file, offense),
          level: SEVERITY_LEVELS.fetch(offense.severity.name, 'warning'),
          message: { text: offense.message },
          locations: [location_for(file, offense)],
          partialFingerprints: fingerprints_for(offense)
        }

        # Suppressed offenses are only reported under `--display-suppressed`.
        # SARIF has a first-class representation for them, so consumers can
        # tell them apart from offenses that were never triggered.
        result[:suppressions] = [suppression_for(offense)] if offense.disabled?
        result
      end

      # The URI is relative to the working directory, which is what consumers
      # expect to resolve against their own checkout. No `uriBaseId`: it would
      # have to be declared under `originalUriBaseIds` to mean anything, and
      # every consumer that matters resolves relative paths without it.
      def location_for(file, offense)
        {
          physicalLocation: {
            artifactLocation: { uri: uri_for(file) },
            region: region_for(offense)
          }
        }
      end

      def region_for(offense)
        # SARIF columns are 1-based and `endColumn` points at the character
        # *after* the region, while `real_last_column` is the last character.
        {
          startLine: offense.first_line,
          startColumn: offense.real_column,
          endLine: offense.last_line,
          endColumn: offense.real_last_column + 1
        }
      end

      # GitHub uses these to match an alert across runs. Without them it falls
      # back to the file path, which makes alerts churn whenever a file moves.
      def fingerprints_for(offense)
        source_line = offense.location.source_line
        { primaryLocationLineHash: Digest::SHA256.hexdigest("#{offense.cop_name}#{source_line}") }
      end

      def suppression_for(offense)
        suppression = { kind: 'inSource' }
        suppression[:justification] = offense.justification if offense.justification
        suppression
      end

      def rule_index_for(file, offense)
        @rule_indexes[offense.cop_name] ||= begin
          @rules << rule_for(file, offense)
          @rules.size - 1
        end
      end

      def rule_for(file, offense)
        cop_class = Cop::Registry.global.find_by_cop_name(offense.cop_name)
        description = description_for(file, offense)
        help_uri = cop_class && Cop::Documentation.url_for(cop_class, config_for(file))

        rule = {
          id: offense.cop_name,
          name: offense.cop_name,
          shortDescription: { text: description },
          fullDescription: { text: description },
          help: help_for(description, help_uri),
          defaultConfiguration: { level: default_level_for(file, offense, cop_class) },
          properties: { tags: [offense.cop_name.split('/').first] }
        }
        rule[:helpUri] = help_uri if help_uri
        rule
      end

      def help_for(description, help_uri)
        help = { text: description }
        help[:markdown] = "#{description}\n\n[Documentation](#{help_uri})" if help_uri
        help
      end

      def description_for(file, offense)
        cop_config(file, offense)['Description'] || offense.cop_name
      end

      def default_level_for(file, offense, cop_class)
        severity = cop_config(file, offense)['Severity'] ||
                   (cop_class&.lint? ? :warning : :convention)

        SEVERITY_LEVELS.fetch(severity.to_sym, 'warning')
      end

      def cop_config(file, offense)
        config_for(file)&.for_cop(offense.cop_name) || {}
      end

      # `file_started` is not called when a formatter is used directly through
      # the API, so there may be no config to consult.
      def config_for(file)
        @config_store&.for_file(file)
      end

      def uri_for(file)
        PathUtil.smart_path(file).tr('\\', '/')
      end
    end
  end
end
