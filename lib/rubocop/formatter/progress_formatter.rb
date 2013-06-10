# encoding: utf-8

module Rubocop
  module Formatter
    class ProgressFormatter < SimpleTextFormatter
      COLOR_FOR_SEVERITY = {
          refactor: :yellow,
        convention: :yellow,
           warning: :magenta,
             error: :red,
             fatal: :red
      }

      def started(target_files)
        super
        @offences_for_files = {}
        output.puts "Inspecting #{target_files.count} files"
      end

      def file_finished(file, offences)
        @total_offence_count += offences.count
        @offences_for_files[file] = offences unless offences.empty?
        report_file_as_mark(file, offences)
      end

      def finished(inspected_files)
        output.puts

        return unless reports_summary?

        output.puts
        output.puts 'Offences:'

        @offences_for_files.each do |file, offences|
          output.puts
          report_file(file, offences.sort)
        end

        report_summary(inspected_files.count, @total_offence_count)
      end

      def report_file_as_mark(file, offences)
        mark = if offences.empty?
                 '.'
               else
                 highest_offence = offences.max do |a, b|
                   a.severity_level <=> b.severity_level
                 end
                 color = COLOR_FOR_SEVERITY[highest_offence.severity]
                 highest_offence.encode_severity.color(color)
               end

        output.write mark
      end
    end
  end
end
