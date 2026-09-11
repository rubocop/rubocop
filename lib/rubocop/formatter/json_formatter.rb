# frozen_string_literal: true

require 'json'

module RuboCop
  module Formatter
    # This formatter formats the report data in JSON format.
    class JSONFormatter < BaseFormatter
      include PathUtil

      attr_reader :output_hash

      def initialize(output, options = {})
        super
        @output_hash = { metadata: metadata_hash, files: [], summary: { offense_count: 0 } }
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
        output.write output_hash.to_json
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
          path:     smart_path(file),
          offenses: offenses.map { |o| hash_for_offense(o) }
        }
      end

      def hash_for_offense(offense)
        hash = {
          severity:    offense.severity.name,
          message:     offense.message,
          cop_name:    offense.cop_name,
          corrected:   offense.corrected?,
          correctable: offense.correctable?,
          location:    hash_for_location(offense)
        }

        # Suppressed offenses appear only under `--display-suppressed`, so
        # these keys are additive for existing consumers.
        if offense.disabled?
          hash[:suppressed] = true
          hash[:justification] = offense.justification
        end

        # The edits autocorrection would make, so a consumer can apply or review
        # them without running autocorrection itself. Additive, and absent when
        # the offense has no correction.
        hash[:correction] = correction_for(offense) unless offense.corrections.empty?

        hash
      end

      def correction_for(offense)
        { safe: offense.correction_safe, edits: edits_for(offense) }
      end

      def edits_for(offense)
        buffer = offense.location.source_buffer

        offense.corrections.map do |correction|
          # Built as a range so the columns follow the same 1-based convention
          # as `hash_for_location`, end-exclusive column included.
          range = ::Parser::Source::Range.new(buffer, correction.begin_pos, correction.end_pos)

          hash_for_edit_range(range).merge!(
            begin_pos: correction.begin_pos,
            end_pos: correction.end_pos,
            replacement: correction.replacement
          )
        end
      end

      def hash_for_edit_range(range)
        {
          start_line: range.line,
          start_column: range.column + 1,
          last_line: range.last_line,
          last_column: range.last_column.zero? ? 1 : range.last_column
        }
      end

      def hash_for_location(offense)
        {
          start_line:   offense.line,
          start_column: offense.real_column,
          last_line:    offense.last_line,
          last_column:  offense.real_last_column,
          length:       offense.location.length,
          # `line` and `column` exist for compatibility.
          # Use `start_line` and `start_column` instead.
          line:         offense.line,
          column:       offense.real_column
        }
      end
    end
  end
end
