# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking for too many lines.
    module TooManyLines
      include ConfigurableMax
      include CodeLength

      MSG = '%s has too many lines. [%d/%d]'.freeze

      private

      def message(length, max_length)
        format(MSG, cop_label, length, max_length)
      end

      def code_length(node)
        lines = node.source.lines.to_a[1...-1] || []

        lines.count { |line| !irrelevant_line(line) }
      end
    end
  end
end
