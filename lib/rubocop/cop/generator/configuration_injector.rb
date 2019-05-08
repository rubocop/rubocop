# frozen_string_literal: true

module RuboCop
  module Cop
    class Generator
      # A class that injects a require directive into the root RuboCop file.
      # It looks for other directives that require files in the same (cop)
      # namespace and injects the provided one in alpha
      class ConfigurationInjector
        TEMPLATE = <<~YAML
          %<badge>s:
            Description: 'TODO: Write a description of the cop.'
            Enabled: true
            VersionAdded: '%<version_added>s'

        YAML

        def initialize(configuration_file_path:, badge:, version_added:)
          @configuration_file_path = configuration_file_path
          @badge = badge
          @version_added = version_added
          @output = output
        end

        def inject
          configuration_entries.insert(find_target_line,
                                       new_configuration_entry)

          File.write(configuration_file_path, configuration_entries.join)

          yield if block_given?
        end

        private

        attr_reader :configuration_file_path, :badge, :version_added, :output

        def configuration_entries
          @configuration_entries ||= File.readlines(configuration_file_path)
        end

        def new_configuration_entry
          format(TEMPLATE, badge: badge, version_added: version_added)
        end

        def find_target_line
          configuration_entries.find.with_index do |line, index|
            next unless cop_name_line?(line)

            return index if badge.to_s < line
          end
          configuration_entries.size - 1
        end

        def cop_name_line?(yaml)
          yaml !~ /^[\s#]/
        end
      end
    end
  end
end
