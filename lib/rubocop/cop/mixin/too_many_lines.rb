# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking for too many lines.
    module TooManyLines
      include ConfigurableMax
      include CodeLength

      MSG = '%<label>s has too many lines. [%<length>d/%<max>d]'

      private

      def message(length, max_length)
        format(MSG, label: cop_label, length: length, max: max_length)
      end

      def code_length(node)
        Metrics::Utils::CodeLengthCalculator.new(node,
                                                 count_comments: count_comments?,
                                                 foldable_types: count_as_one).calculate
      end
    end
  end
end
