# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter displays the list of offended cops with a count of how
    # many offences of their kind were found. Ordered by desc offence count
    #
    # Here's the format:
    #
    # (26)  LineLength
    # (3)   OneLineConditional
    class OffenceCountFormatter < BaseFormatter
      attr_reader :offence_counts

      def started(target_files)
        super
        @offence_counts = Hash.new(0)
      end

      def file_finished(file, offences)
        offences.each { |o| @offence_counts[o.cop_name] += 1 }
      end

      def finished(inspected_files)
        report_summary(inspected_files.count,
                       ordered_offence_counts(@offence_counts))
      end

      def report_summary(file_count, offence_counts)
        output.puts

        offence_count = total_offence_count(offence_counts)
        offence_counts.each do |cop_name, count|
          output.puts "#{count.to_s.ljust(offence_count.to_s.length + 2)}" +
                      "#{cop_name}\n"
        end
        output.puts
      end

      def ordered_offence_counts(offence_counts)
        Hash[offence_counts.sort_by { |k, v| v }.reverse]
      end

      def total_offence_count(offence_counts = {})
        offence_counts.values.inject(0, :+)
      end
    end
  end
end
