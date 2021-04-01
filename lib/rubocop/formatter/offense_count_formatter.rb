# frozen_string_literal: true

module RuboCop
  module Formatter
    # This formatter displays the list of offended cops with a count of how
    # many offenses of their kind were found. Ordered by desc offense count
    #
    # Here's the format:
    #
    # 26  LineLength
    # 3   OneLineConditional
    # --
    # 29  Total
    class OffenseCountFormatter < BaseFormatter
      attr_reader :offense_counts

      def started(target_files)
        super
        @offense_counts = Hash.new(0)

        return unless output.tty?

        file_phrase = target_files.count == 1 ? 'file' : 'files'

        # 185/407 files |====== 45 ======>                    |  ETA: 00:00:04
        # %c / %C       |       %w       >         %i         |       %e
        bar_format = " %c/%C #{file_phrase} |%w>%i| %e "

        @progressbar = ProgressBar.create(
          output: output,
          total: target_files.count,
          format: bar_format,
          autostart: false
        )
        @progressbar.start
      end

      def file_finished(_file, offenses)
        offenses.each { |o| @offense_counts[o.cop_name] += 1 }
        @progressbar.increment if instance_variable_defined?(:@progressbar)
      end

      def finished(_inspected_files)
        report_summary(@offense_counts)
      end

      # rubocop:disable Metrics/AbcSize
      def report_summary(offense_counts)
        per_cop_counts = ordered_offense_counts(offense_counts)
        total_count = total_offense_count(offense_counts)

        output.puts

        per_cop_counts.each do |cop_name, count|
          output.puts "#{count.to_s.ljust(total_count.to_s.length + 2)}" \
                      "#{cop_name}\n"
        end
        output.puts '--'
        output.puts "#{total_count}  Total"

        output.puts
      end
      # rubocop:enable Metrics/AbcSize

      def ordered_offense_counts(offense_counts)
        offense_counts.sort_by { |k, v| [-v, k] }.to_h
      end

      def total_offense_count(offense_counts)
        offense_counts.values.sum
      end
    end
  end
end
