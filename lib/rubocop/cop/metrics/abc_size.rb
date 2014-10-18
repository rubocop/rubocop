# encoding: utf-8

module RuboCop
  module Cop
    module Metrics
      # This cop checks that the ABC size of methods is not higher than the
      # configured maximum. The ABC size is based on assignments, branches
      # (method calls), and conditions. See http://c2.com/cgi/wiki?AbcMetric
      class AbcSize < Cop
        include MethodComplexity

        MSG = 'Assignment Branch Condition size for %s is too high. [%.4g/%.4g]'
        BRANCH_NODES = [:send]
        CONDITION_NODES = CyclomaticComplexity::COUNTED_NODES

        private

        def complexity(node)
          a = node.each_node(ASGN_NODES).count
          b = node.each_node(BRANCH_NODES).count
          c = node.each_node(CONDITION_NODES).count
          Math.sqrt(a**2 + b**2 + c**2).round(2)
        end
      end
    end
  end
end
