# frozen_string_literal: true

# require 'set'

module RuboCop
  # This class finds changed files by parsing git changes
  class LineupFinder
    def changed_files
      @changed_files ||= git_diff_name_only
      .lines
      .map(&:chomp)
      .grep(/\.rb$/)
      .map { |file| File.absolute_path(file) }
    end

    private

    def git_diff_name_only
      `git diff --diff-filter=AM --name-only HEAD`
    end
  end
end
