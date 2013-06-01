# encoding: utf-8

module Rubocop
  module Formatter
    class PlainTextFormatter < BaseFormatter
      attr_accessor :reports_summary
      alias_method :reports_summary?, :reports_summary

      def started(all_files)
        @total_offence_count = 0
      end

      def file_finished(file, offences)
        return if offences.empty?
        @total_offence_count += offences.count
        offences.sort_by!(&:line_number)
        report_file(file, offences)
      end

      def finished(processed_files)
        if reports_summary?
          report_summary(processed_files.count, @total_offence_count)
        end
      end

      def report_file(file, offences)
        output.puts "== #{file} ==".color(:yellow)
        output.puts offences.join("\n")
      end

      def report_summary(file_count, offence_count)
        summary = ''

        plural = file_count == 0 || file_count > 1 ? 's' : ''
        summary << "#{file_count} file#{plural} inspected, "

        offences_string = case offence_count
                          when 0 then 'no offences'
                          when 1 then '1 offence'
                          else "#{offence_count} offences"
                          end
        summary << "#{offences_string} detected"
          .color(offence_count.zero? ? :green : :red)

        output.puts
        output.puts summary
      end
    end
  end
end
