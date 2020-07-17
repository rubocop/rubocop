# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking length of code segments.
    module CodeLength
      include ConfigurableMax

      MSG = '%<label>s has too many lines. [%<length>d/%<max>d]'

      private

      def message(length, max_length)
        format(MSG, label: cop_label, length: length, max: max_length)
      end

      def max_length
        cop_config['Max']
      end

      def count_comments?
        cop_config['CountComments']
      end

      def count_as_one
        Array(cop_config['CountAsOne']).map(&:to_sym)
      end

      def check_code_length(node)
        # Skip costly calculation when definitely not needed
        return if node.line_count <= max_length

        calculator = Metrics::Utils::CodeLengthCalculator.new(node, processed_source,
                                                              count_comments: count_comments?,
                                                              foldable_types: count_as_one)
        length = calculator.calculate
        return if length <= max_length

        location = node.casgn_type? ? :name : :expression

        add_offense(node, location: location,
                          message: message(length, max_length)) do
          self.max = length
        end
      end
    end
  end
end
