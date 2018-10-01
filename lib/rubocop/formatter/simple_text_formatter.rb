# frozen_string_literal: true

require_relative 'colorizable'
require_relative 'text_util'

module RuboCop
  module Formatter
    # A basic formatter that displays only files with offenses.
    # Offenses are displayed at compact form - just the
    # location of the problem and the associated message.
    class SimpleTextFormatter < BaseFormatter
      include Colorizable
      include PathUtil

      COLOR_FOR_SEVERITY = {
        refactor: :yellow,
        convention: :yellow,
        warning: :magenta,
        error: :red,
        fatal: :red
      }.freeze

      def started(_target_files)
        @total_offense_count = 0
        @total_correction_count = 0
      end

      def file_finished(file, offenses)
        return if offenses.empty?

        count_stats(offenses)
        report_file(file, offenses)
      end

      def finished(inspected_files)
        report_summary(inspected_files.count,
                       @total_offense_count,
                       @total_correction_count)
      end

      def report_file(file, offenses)
        output.puts yellow("== #{smart_path(file)} ==")

        offenses.each do |o|
          output.printf("%s:%3d:%3d: %s\n",
                        colored_severity_code(o),
                        o.line, o.real_column, message(o))
        end
      end

      def report_summary(file_count, offense_count, correction_count)
        report = Report.new(file_count,
                            offense_count,
                            correction_count,
                            rainbow)

        output.puts
        output.puts report.summary
      end

      private

      def count_stats(offenses)
        @total_offense_count += offenses.count
        @total_correction_count += offenses.count(&:corrected?)
      end

      def colored_severity_code(offense)
        color = COLOR_FOR_SEVERITY[offense.severity.name]
        colorize(offense.severity.code, color)
      end

      def annotate_message(msg)
        msg.gsub(/`(.*?)`/m, yellow('\1'))
      end

      def message(offense)
        message = offense.corrected? ? green('[Corrected] ') : ''
        "#{message}#{annotate_message(offense.message)}"
      end

      # A helper class for building the report summary text.
      class Report
        include Colorizable
        include TextUtil

        def initialize(file_count, offense_count, correction_count, rainbow)
          @file_count = file_count
          @offense_count = offense_count
          @correction_count = correction_count
          @rainbow = rainbow
        end

        def summary
          if @correction_count > 0
            "#{files} inspected, #{offenses} detected, #{corrections} corrected"
          else
            "#{files} inspected, #{offenses} detected"
          end
        end

        private

        attr_reader :rainbow

        def files
          pluralize(@file_count, 'file')
        end

        def offenses
          text = pluralize(@offense_count, 'offense', no_for_zero: true)
          color = @offense_count.zero? ? :green : :red

          colorize(text, color)
        end

        def corrections
          text = pluralize(@correction_count, 'offense')
          color = @correction_count == @offense_count ? :green : :cyan

          colorize(text, color)
        end
      end
    end
  end
end
