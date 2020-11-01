# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      # This cop checks that the ABC size of methods is not higher than the
      # configured maximum. The ABC size is based on assignments, branches
      # (method calls), and conditions. See http://c2.com/cgi/wiki?AbcMetric
      # and https://en.wikipedia.org/wiki/ABC_Software_Metric.
      #
      # You can set literals you want to fold with `CountAsOne`.
      # Available are: 'array', 'hash'. Each literal
      # will be counted as one branch regardless of its values branch counts,
      # but only if any value has branches (e.g. is/includes a method call)
      #
      # @example CountAsOne: ['array', 'hash']
      #
      #   def m
      #     Klass.new([
      #       private_m.foo,
      #       private_m.bar
      #     ]) # 1 (construstor) + 1 (array includes calls)
      #
      #     Klass.new(
      #       key: private_m.foo,
      #       bar: private_m.bar
      #     ) # 1 (construstor) + 1 (hash values includes calls)
      #   end
      #
      class AbcSize < Base
        include MethodComplexity

        MSG = 'Assignment Branch Condition size for %<method>s is too high. ' \
              '[%<abc_vector>s %<complexity>.4g/%<max>.4g]'

        private

        def complexity(node)
          Utils::AbcSizeCalculator.calculate(node, foldable_types: count_as_one)
        end

        def count_as_one
          Array(cop_config['CountAsOne']).map(&:to_sym)
        end
      end
    end
  end
end
