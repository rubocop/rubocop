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
        @problems = {}
      end

      def started(target_files)
        output_hash[:summary][:target_file_count] = target_files.count
      end

      def file_problems(file, errors, warnings)
        @problems[file] = hash_for_problems(file, errors, warnings)
      end

      def file_finished(file, offenses)
        entry = hash_for_file(file, offenses)
        problems = @problems.delete(file)
        entry.merge!(problems) if problems

        output_hash[:files] << entry
        output_hash[:summary][:offense_count] += offenses.count
      end

      def finished(inspected_files)
        output_hash[:summary][:inspected_file_count] = inspected_files.count
        output_hash[:summary].merge!(problem_counts(output_hash[:files]))
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

      # A cop that crashes fails once per node it visits, so messages that
      # differ only in their line and column are listed once, at the first place
      # they happened. They name the file the way its entry does. The keys are
      # absent when there's nothing to report, which keeps them additive for
      # existing consumers.
      def hash_for_problems(file, errors, warnings)
        return {} if errors.empty? && warnings.empty?

        path = smart_path(file)
        location = /#{Regexp.escape(File.expand_path(file))}((?::\d+)*)/

        { errors: errors, warnings: warnings }.filter_map do |key, messages|
          next if messages.empty?

          messages = messages.uniq { |message| message.gsub(location, '') }
          [key, messages.map { |message| message.gsub(location) { path + Regexp.last_match(1) } }]
        end.to_h
      end

      def problem_counts(files)
        {
          error_count: files.sum { |f| f[:errors]&.size.to_i },
          warning_count: files.sum { |f| f[:warnings]&.size.to_i }
        }.reject { |_, count| count.zero? }
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
