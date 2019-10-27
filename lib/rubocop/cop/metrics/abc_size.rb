# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks that the ABC size of methods is not higher than the
      # configured maximum. The ABC size is based on assignments, branches
      # (method calls), and conditions. See http://c2.com/cgi/wiki?AbcMetric
      # and https://en.wikipedia.org/wiki/ABC_Software_Metric.
      class AbcSize < Cop
        include MethodComplexity

        MSG = 'Assignment Branch Condition size for %<method>s is too high. ' \
              '[%<abc_vector>s %<complexity>.4g/%<max>.4g]'

        private

        def complexity(node)
          Utils::AbcSizeCalculator.calculate(node)
        end
      end
    end
  end
end
