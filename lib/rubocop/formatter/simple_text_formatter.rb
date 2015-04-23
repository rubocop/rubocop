# encoding: utf-8

require 'rubocop/formatter/colorizable'
require 'rubocop/formatter/text_util'

module RuboCop
  module Formatter
    # A basic formatter that displays only files with offenses.
    # Offenses are displayed at compact form - just the
    # location of the problem and the associated message.
    class SimpleTextFormatter < BaseFormatter
      include Colorizable, PathUtil, TextUtil

      COLOR_FOR_SEVERITY = {
        refactor:   :yellow,
        convention: :yellow,
        warning:    :magenta,
        error:      :red,
        fatal:      :red
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
        summary = pluralize(file_count, 'file')
        summary << ' inspected, '

        offenses_text = pluralize(offense_count, 'offense', no_for_zero: true)
        offenses_text << ' detected'
        summary << colorize(offenses_text, offense_count.zero? ? :green : :red)

        if correction_count > 0
          summary << ', '
          correction_text = pluralize(correction_count, 'offense')
          correction_text << ' corrected'
          color = correction_count == offense_count ? :green : :cyan
          summary << colorize(correction_text, color)
        end

        output.puts
        output.puts summary
      end

      private

      def count_stats(offenses)
        @total_offense_count += offenses.count
        @total_correction_count += offenses.count(&:corrected?)
      end

      def smart_path(path)
        # Ideally, we calculate this relative to the project root.
        base_dir = Dir.pwd

        if path.start_with? base_dir
          relative_path(path, base_dir)
        else
          path
        end
      end

      def colored_severity_code(offense)
        color = COLOR_FOR_SEVERITY[offense.severity.name]
        colorize(offense.severity.code, color)
      end

      def annotate_message(msg)
        msg.gsub(/`(.*?)`/, Rainbow('\1').yellow)
      end

      def message(offense)
        message = offense.corrected? ? green('[Corrected] ') : ''
        message << annotate_message(offense.message)
      end
    end
  end
end
