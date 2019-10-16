# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the logic for autocorrect behavior for a cop.
    module AutocorrectLogic
      # An offense location can be either a Parser::Source::Buffer or a
      # Parser::Source::Buffer - this normalizes the interface in regards to
      # getting the name of the source file.
      module NormalizeLocationInterface
        refine Parser::Source::Map do
          def source_buffer
            expression.source_buffer
          end
        end
      end
      using NormalizeLocationInterface

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
        respond_to?(:autocorrect)
      end

      def disable_uncorrectable?
        @options[:disable_uncorrectable] == true
      end

      def skip_correction_for?(loc)
        # allow correcting (or not correcting) only selected offenses
        include_list = @options[:auto_correct_include]
        exclude_list = @options[:auto_correct_exclude]

        return false if include_list.nil? && exclude_list.nil?

        path = loc.source_buffer.name
        id = OffenseIdentifier.new(path, loc.line, loc.column + 1, cop_name)

        if include_list
          !include_list.include?(id)
        else
          exclude_list.include?(id)
        end
      end

      def autocorrect_enabled?
        # allow turning off autocorrect on a cop by cop basis
        return true unless cop_config

        return false if cop_config['AutoCorrect'] == false

        if @options.fetch(:safe_auto_correct, false)
          return cop_config.fetch('SafeAutoCorrect', true)
        end

        true
      end

      def disable_offense(node)
        range = node.location.expression
        eol_comment = " # rubocop:todo #{cop_name}"
        needed_line_length = range.column +
                             (range.source_line + eol_comment).length
        if needed_line_length <= max_line_length
          disable_offense_at_end_of_line(range_of_first_line(range),
                                         eol_comment)
        else
          disable_offense_before_and_after(range_by_lines(range))
        end
      end

      private

      def range_of_first_line(range)
        begin_of_first_line = range.begin_pos - range.column
        end_of_first_line = begin_of_first_line + range.source_line.length

        Parser::Source::Range.new(range.source_buffer,
                                  begin_of_first_line,
                                  end_of_first_line)
      end

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

      def max_line_length
        config.for_cop('Metrics/LineLength')['Max'] || 80
      end

      def disable_offense_at_end_of_line(range, eol_comment)
        ->(corrector) { corrector.insert_after(range, eol_comment) }
      end

      def disable_offense_before_and_after(range_by_lines)
        lambda do |corrector|
          range_with_newline = range_by_lines.resize(range_by_lines.size + 1)
          leading_whitespace = range_by_lines.source_line[/^\s*/]

          corrector.insert_before(
            range_with_newline,
            "#{leading_whitespace}# rubocop:todo #{cop_name}\n"
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
