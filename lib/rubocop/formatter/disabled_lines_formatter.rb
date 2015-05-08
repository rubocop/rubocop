# encoding: utf-8
module RuboCop
  module Formatter
    # A basic formatter that displays the lines disabled
    # inline comments.
    class DisabledLinesFormatter < BaseFormatter
      include PathUtil
      include Colorizable

      attr_reader :cop_disabled_line_ranges

      def started(_target_files)
        @cop_disabled_line_ranges = {}
        @offenses = {}
      end

      def file_started(file, options)
        return unless options[:cop_disabled_line_ranges]

        @cop_disabled_line_ranges[file] =
          options[:cop_disabled_line_ranges]
      end

      def file_finished(file, offenses)
        @offenses[file] = offenses
      end

      def wanted_offenses(offenses)
        offenses.select(&:disabled?)
      end

      def finished(_inspected_files)
        cops_disabled_in_comments_summary
      end

      private

      def cops_disabled_in_comments_summary
        summary = "\nCops disabled line ranges:\n\n"

        @cop_disabled_line_ranges.each do |file, disabled_cops|
          @offenses[file] ||= []
          disabled_cops.each do |cop, line_ranges|
            cop_offenses = @offenses[file].select { |o| o.cop_name == cop }
            line_ranges.each do |line_range|
              summary << "#{cyan(smart_path(file))}:#{line_range}: #{cop}"
              if cop_offenses.none? { |o| line_range.include?(o.line) }
                summary << red(' (unnecessary)')
              end
              summary << "\n"
            end
          end
        end

        output.puts summary
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
    end
  end
end
