# encoding: utf-8

require 'json'
require 'pathname'

module Rubocop
  module Formatter
    # This formatter formats the report data in JSON format.
    class JSONFormatter < BaseFormatter
      attr_reader :output_hash

      def initialize(output)
        super
        @output_hash = {
          metadata: metadata_hash,
          files:    [],
          summary:  { offence_count: 0 }
        }
      end

      def started(target_files)
        output_hash[:summary][:target_file_count] = target_files.count
      end

      def file_finished(file, offences)
        output_hash[:files] << hash_for_file(file, offences)
        output_hash[:summary][:offence_count] += offences.count
      end

      def finished(inspected_files)
        output_hash[:summary][:inspected_file_count] = inspected_files.count
        output.write output_hash.to_json
      end

      def metadata_hash
        {
          rubocop_version: Rubocop::Version::STRING,
          ruby_engine:     RUBY_ENGINE,
          ruby_version:    RUBY_VERSION,
          ruby_patchlevel: RUBY_PATCHLEVEL.to_s,
          ruby_platform:   RUBY_PLATFORM
        }
      end

      def hash_for_file(file, offences)
        {
          path:     relative_path(file),
          offences: offences.map { |o| hash_for_offence(o) }
        }
      end

      def hash_for_offence(offence)
        {
          severity: offence.severity,
          message:  offence.message,
          cop_name: offence.cop_name,
          corrected: offence.corrected?,
          location: hash_for_location(offence)
        }
      end

      # TODO: Consider better solution for Offence#real_column.
      def hash_for_location(offence)
        {
          line:   offence.line,
          column: offence.real_column
        }
      end

      private

      def relative_path(path)
        Pathname.new(path).relative_path_from(Pathname.getwd).to_s
      end
    end
  end
end
