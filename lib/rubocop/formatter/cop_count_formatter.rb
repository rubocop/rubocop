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
    class CopCountFormatter < BaseFormatter

      attr_reader :cop_offences

      def started(target_files)
        super
        @cop_offences = Hash.new(0)
      end

      def file_finished(file, offences)
        offences.each { |o| @cop_offences[o.cop_name] += 1 }
      end

      def finished(inspected_files)
        report_summary(inspected_files.count,
                       ordered_cop_offences(@cop_offences))
      end

      def report_summary(file_count, cop_offences)
        output.puts

        offence_count = total_offence_count(cop_offences)
        cop_offences.each do |cop_name, count|
          count_string = "(#{count.to_s})"
          output.puts "#{count_string.ljust(offence_count + 4)}#{cop_name}\n"
        end
        output.puts
      end

      def ordered_cop_offences(cop_offences)
        Hash[cop_offences.sort_by { |k, v| v }.reverse]
      end

      def total_offence_count(cop_offences = {})
        cop_offences.values.inject(0, :+)
      end
    end
  end
end
