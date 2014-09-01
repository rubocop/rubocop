# encoding: utf-8

require 'erb'
require 'pathname'

module RuboCop
  module Formatter
    # This formatter saves the output as a html file.
    class HTMLFormatter < BaseFormatter
      include PathUtil

      attr_reader :output_hash

      def initialize(output)
        super
        @output_hash = {
          metadata: metadata_hash,
          files:    [],
          summary:  { offense_count: 0 }
        }
      end

      def started(target_files)
        output_hash[:summary][:target_file_count] = target_files.count
      end

      def file_finished(file, offenses)
        output_hash[:files] << hash_for_file(file, offenses)
        output_hash[:summary][:offense_count] += offenses.count
      end

      def finished(inspected_files)
        output_hash[:summary][:inspected_file_count] = inspected_files.count
        template = File.read(File
          .expand_path('../../../../assets/output.html.erb', __FILE__))
        erb = ERB.new(template)
        html_content = erb.result(binding)
        output.write html_content
      end

      def metadata_hash
        {
          rubocop_version: RuboCop::Version::STRING,
          ruby_engine:     RUBY_ENGINE,
          ruby_version:    RUBY_VERSION,
          ruby_patchlevel: RUBY_PATCHLEVEL.to_s,
          ruby_platform:   RUBY_PLATFORM
        }
      end

      def hash_for_file(file, offenses)
        {
          path:     relative_path(file),
          offenses: offenses.map { |o| hash_for_offense(o) }
        }
      end

      def hash_for_offense(offense)
        {
          severity: offense.severity.name,
          message:  offense.message,
          cop_name: offense.cop_name,
          corrected: offense.corrected?,
          location: hash_for_location(offense)
        }
      end

      # TODO: Consider better solution for Offense#real_column.
      def hash_for_location(offense)
        {
          line:   offense.line,
          column: offense.real_column,
          length: offense.location.length,
          source_line: offense.location.source_line,
          highlight: highlight_line(offense.location)
        }
      end

      def highlight_line(location)
        column_length = if location.begin.line == location.end.line
                          location.column_range.count
                        else
                          location.source_line.length - location.column
                        end

        ' ' * location.column + '^' * column_length
      end
    end
  end
end
