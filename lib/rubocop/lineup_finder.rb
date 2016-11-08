# frozen_string_literal: true

# require 'set'

module RuboCop
  # This class finds changed files by parsing git changes
  class LineupFinder
    attr_reader :diff_info

    def changed_files
      @changed_files ||= git_diff_name_only
      .lines
      .map(&:chomp)
      .grep(/\.rb$/)
      .map { |file| File.absolute_path(file) }
    end

    def changed_files_and_lines
      @diff_info ||= Hash[
        changed_files.collect do |file|
          [file, line_change_info(file)]
        end
      ]

      @changes ||= Hash[
        diff_info.collect do |filename, line_change_info|
          mask = line_change_info.collect do |changed_line_number, number_of_changed_lines|
            Array(changed_line_number .. (changed_line_number + number_of_changed_lines))
          end.flatten

          [filename, mask]
        end
      ]
    end

    private

    def git_diff_name_only
      `git diff --diff-filter=AM --name-only HEAD`
    end
  end
end
