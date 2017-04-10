# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the logic for autocorrect behavior for a cop.
    module AutocorrectLogic
      def autocorrect?
        autocorrect_requested? && correctable? && autocorrect_enabled?
      end

      def autocorrect_requested?
        @options.fetch(:auto_correct, false)
      end

      def correctable?
        support_autocorrect? || disable_uncorrectable?
      end

      def support_autocorrect?
        respond_to?(:autocorrect, true)
      end

      def disable_uncorrectable?
        @options[:disable_uncorrectable] == true
      end

      def autocorrect_enabled?
        # allow turning off autocorrect on a cop by cop basis
        return true unless cop_config
        cop_config['AutoCorrect'] != false
      end

      def disable_offense(node)
        range = node.location.expression
        range_by_lines = range_by_lines(range)

        if range.line == range.last_line
          disable_offense_at_end_of_line(range_by_lines)
        else
          disable_offense_before_and_after(range_by_lines)
        end
      end

      private

      # Expand the given range to include all of any lines it covers. Does not
      # include newline at end of the last line.
      def range_by_lines(range)
        begin_of_first_line = range.begin_pos - range.column

        last_line = range.source_buffer.source_line(range.last_line)
        last_line_offset = last_line.length - range.last_column
        end_of_last_line = range.end_pos + last_line_offset

        Parser::Source::Range.new(range.source_buffer,
                                  begin_of_first_line,
                                  end_of_last_line)
      end

      def disable_offense_at_end_of_line(range_by_lines)
        lambda do |corrector|
          corrector.insert_after(
            range_by_lines,
            " # rubocop:disable #{cop_name}"
          )
        end
      end

      def disable_offense_before_and_after(range_by_lines)
        lambda do |corrector|
          range_with_newline = range_by_lines.resize(range_by_lines.size + 1)
          leading_whitespace = range_by_lines.source_line[/^\s*/]

          corrector.insert_before(
            range_with_newline,
            "#{leading_whitespace}# rubocop:disable #{cop_name}\n"
          )
          corrector.insert_after(
            range_with_newline,
            "#{leading_whitespace}# rubocop:enable #{cop_name}\n"
          )
        end
      end
    end
  end
end
