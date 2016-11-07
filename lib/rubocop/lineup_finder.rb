# frozen_string_literal: true

# require 'set'

module RuboCop
  # This class finds changes by parsing git changes
  class LineupFinder
    def changed_files
      @changed_files ||=
        git_diff_name_only
        .lines
        .map(&:chomp)
        .grep(/\.rb$/)
        .map { |filename| File.absolute_path(filename) }
    end

    def changes_at_location?(location)
      location_lines = Array(location.first_line..location.last_line)
      filename = location.source_buffer.name

      !(location_lines & changed_lines(filename)).empty?
    end

    def changed_lines(filename)
      changed_files_and_lines[filename] || []
    end

    private

    def git_diff_name_only
      `git diff --diff-filter=AM --name-only HEAD`
    end

    def git_diff_zero_unified(filename)
      `git diff -U0 HEAD #{filename}`
    end

    def changed_files_and_lines
      @changes ||= Hash[
        changed_files.collect do |filename|
          [filename, changed_line_mask(filename)]
        end
      ]
    end

    def changed_line_mask(filename)
      ranges_to_mask(changed_line_ranges(filename))
    end

    def changed_line_ranges(filename)
      git_diff_zero_unified(filename)
        .each_line
        .grep(/@@ -(\d+)(?:,)?(\d+)? \+(\d+)(?:,)?(\d+)? @@/) do
          [
            Regexp.last_match[3].to_i,
            (Regexp.last_match[4] || 1).to_i
          ]
        end
    end

    def ranges_to_mask(ranges)
      ranges.collect do |line_range_start, number_of_changed_lines|
        if number_of_changed_lines.zero?
          []
        else
          line_range_end = line_range_start + number_of_changed_lines - 1
          Array(line_range_start..line_range_end)
        end
      end.flatten
    end
  end
end
