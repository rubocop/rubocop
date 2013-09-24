# encoding: utf-8

module Rubocop
  module Formatter
    # A basic formatter that displays only files with offences.
    # Offences are displayed at compact form - just the
    # location of the problem and the associated message.
    class SimpleTextFormatter < BaseFormatter
      COLOR_FOR_SEVERITY = {
        refactor:   :yellow,
        convention: :yellow,
        warning:    :magenta,
        error:      :red,
        fatal:      :red
      }.freeze

      def started(target_files)
        @total_offence_count = 0
        @total_correction_count = 0
      end

      def file_finished(file, offences)
        return if offences.empty?
        count_stats(offences)
        report_file(file, offences)
      end

      def finished(inspected_files)
        report_summary(inspected_files.count,
                       @total_offence_count,
                       @total_correction_count)
      end

      def report_file(file, offences)
        output.puts "== #{smart_path(file)} ==".color(:yellow)

        offences.each do |o|
          output.printf("%s:%3d:%3d: %s\n",
                        colored_severity_code(o),
                        o.line, o.real_column, message(o))
        end
      end

      def report_summary(file_count, offence_count, correction_count)
        summary = pluralize(file_count, 'file')
        summary << ' inspected, '

        offences_text = pluralize(offence_count, 'offence', no_for_zero: true)
        offences_text << ' detected'
        summary << offences_text.color(offence_count.zero? ? :green : :red)

        if correction_count > 0
          summary << ', '
          correction_text = pluralize(correction_count, 'offence')
          correction_text << ' corrected'
          color = correction_count == offence_count ? :green : :cyan
          summary << correction_text.color(color)
        end

        output.puts
        output.puts summary
      end

      private

      def count_stats(offences)
        @total_offence_count += offences.count
        @total_correction_count += offences.select(&:corrected?).count
      end

      def smart_path(path)
        if path.start_with?(Dir.pwd)
          Pathname.new(path).relative_path_from(Pathname.getwd).to_s
        else
          path
        end
      end

      def colored_severity_code(offence)
        color = COLOR_FOR_SEVERITY[offence.severity]
        offence.severity_code.color(color)
      end

      def message(offence)
        message = offence.corrected? ? '[Corrected] '.color(:green) : ''
        message << offence.message
      end

      def pluralize(number, thing, options = {})
        text = ''

        if number == 0 && options[:no_for_zero]
          text = 'no'
        else
          text << number.to_s
        end

        text << " #{thing}"
        text << 's' unless number == 1

        text
      end
    end
  end
end
