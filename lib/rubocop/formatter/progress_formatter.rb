# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter display dots for files with no offences and
    # letters for files with problems in the them. In the end it
    # appends the regular report data in the clang style format.
    class ProgressFormatter < ClangStyleFormatter
      def started(target_files)
        super
        @offences_for_files = {}
        file_phrase = target_files.count == 1 ? 'file' : 'files'
        output.puts "Inspecting #{target_files.count} #{file_phrase}"
      end

      def file_finished(file, offences)
        unless offences.empty?
          count_stats(offences)
          @offences_for_files[file] = offences
        end

        report_file_as_mark(file, offences)
      end

      def finished(inspected_files)
        output.puts

        unless @offences_for_files.empty?
          output.puts
          output.puts 'Offences:'
          output.puts

          @offences_for_files.each do |file, offences|
            report_file(file, offences)
          end
        end

        report_summary(inspected_files.count,
                       @total_offence_count,
                       @total_correction_count)
      end

      def report_file_as_mark(file, offences)
        mark = if offences.empty?
                 green('.')
               else
                 highest_offence = offences.max do |a, b|
                   a.severity_level <=> b.severity_level
                 end
                 colored_severity_code(highest_offence)
               end

        output.write mark
      end
    end
  end
end
