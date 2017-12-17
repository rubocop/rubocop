# frozen_string_literal: true

module RuboCop
  module Cop
    # This module does auto-correction of nodes that should just be moved to
    # the left or to the right, amount being determined by the instance
    # variable @column_delta.
    module Alignment
      private

      SPACE = ' '.freeze

      attr_reader :column_delta

      def configured_indentation_width
        cop_config['IndentationWidth'] ||
          config.for_cop('IndentationWidth')['Width']
      end

      def indentation(node)
        offset(node) + (SPACE * configured_indentation_width)
      end

      def offset(node)
        SPACE * node.loc.column
      end

      def check_alignment(items, base_column = nil)
        unless items.empty?
          base_column ||= display_column(items.first.source_range)
        end

        each_bad_alignment(items, base_column) do |current|
          expr = current.source_range
          if offenses.any? { |o| within?(expr, o.location) }
            # If this offense is within a line range that is already being
            # realigned by autocorrect, we report the offense without
            # autocorrecting it. Two rewrites in the same area by the same
            # cop can not be handled. The next iteration will find the
            # offense again and correct it.
            add_offense(nil, location: expr)
          else
            add_offense(current)
          end
        end
      end

      def each_bad_alignment(items, base_column)
        prev_line = -1
        items.each do |current|
          if current.loc.line > prev_line &&
             begins_its_line?(current.source_range)
            @column_delta = base_column - display_column(current.source_range)

            yield current if @column_delta.nonzero?
          end
          prev_line = current.loc.line
        end
      end
    end
  end
end
