# frozen_string_literal: true

module RuboCop
  module Formatter
    # This formatter formats report data as GitHub Workflow commands resulting
    # in GitHub check annotations when run within GitHub Actions.
    class GitHubActionsFormatter < BaseFormatter
      ESCAPE_MAP = { '%' => '%25', "\n" => '%0A', "\r" => '%0D' }.freeze

      def file_finished(file, offenses)
        offenses.each { |offense| report_offense(file, offense) }
      end

      private

      def github_escape(string)
        string.gsub(Regexp.union(ESCAPE_MAP.keys), ESCAPE_MAP)
      end

      def minimum_severity_to_fail
        @minimum_severity_to_fail ||= begin
          # Unless given explicitly as `fail_level`, `:info` severity offenses do not fail
          name = options.fetch(:fail_level, :refactor)
          RuboCop::Cop::Severity.new(name)
        end
      end

      def github_severity(offense)
        offense.severity < minimum_severity_to_fail ? 'warning' : 'error'
      end

      def report_offense(file, offense)
        output.printf(
          "\n::%{severity} file=%{file},line=%{line},col=%{column}::%{message}\n",
          severity: github_severity(offense),
          file: PathUtil.smart_path(file),
          line: offense.line,
          column: offense.real_column,
          message: github_escape(offense.message)
        )
      end
    end
  end
end
