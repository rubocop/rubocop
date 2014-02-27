# encoding: utf-8

module Rubocop
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
      end

      def file_finished(file, offenses)
        offenses.each { |o| @offense_counts[o.cop_name] += 1 }
      end

      def finished(inspected_files)
        report_summary(inspected_files.count,
                       ordered_offense_counts(@offense_counts))
      end

      def report_summary(file_count, offense_counts)
        output.puts

        offense_count = total_offense_count(offense_counts)
        offense_counts.each do |cop_name, count|
          output.puts "#{count.to_s.ljust(offense_count.to_s.length + 2)}" \
                      "#{cop_name}\n"
        end
        output.puts '--'
        output.puts "#{offense_count}  Total"

        output.puts
      end

      def ordered_offense_counts(offense_counts)
        Hash[offense_counts.sort_by { |k, v| [-v, k] }]
      end

      def total_offense_count(offense_counts = {})
        offense_counts.values.inject(0, :+)
      end
    end
  end
end
