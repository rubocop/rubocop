# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter display dots for files with no offences and
    # letters for files with problems in the them. In the end it
    # appends the regular report data in the clang style format.
    class ProgressFormatter < ClangStyleFormatter
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

        unless @offences_for_files.empty?
          output.puts
          output.puts 'Offences:'
          output.puts

          @offences_for_files.each do |file, offences|
            report_file(file, offences)
          end
        end

        report_summary(inspected_files.count, @total_offence_count)
      end

      def report_file_as_mark(file, offences)
        mark = if offences.empty?
                 '.'.color(:green)
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
