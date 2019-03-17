# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      module Utils
        # > ABC is .. a software size metric .. computed by counting the number
        # > of assignments, branches and conditions for a section of code.
        # > http://c2.com/cgi/wiki?AbcMetric
        #
        # We separate the *calculator* from the *cop* so that the calculation,
        # the formula itself, is easier to test.
        class AbcSizeCalculator
          # > Branch -- an explicit forward program branch out of scope -- a
          # > function call, class method call ..
          # > http://c2.com/cgi/wiki?AbcMetric
          BRANCH_NODES = %i[send csend].freeze

          # > Condition -- a logical/Boolean test, == != <= >= < > else case
          # > default try catch ? and unary conditionals.
          # > http://c2.com/cgi/wiki?AbcMetric
          CONDITION_NODES = CyclomaticComplexity::COUNTED_NODES.freeze

          def self.calculate(node)
            new(node).calculate
          end

          def initialize(node)
            @assignment = 0
            @branch = 0
            @condition = 0
            @node = node
          end

          def calculate
            @node.each_node do |child|
              if child.assignment?
                @assignment += 1
              elsif BRANCH_NODES.include?(child.type)
                evaluate_branch_nodes(child)
              elsif CONDITION_NODES.include?(child.type)
                @condition += 1 if node_has_else_branch?(child)
                @condition += 1
              end
            end

            Math.sqrt(@assignment**2 + @branch**2 + @condition**2).round(2)
          end

          def evaluate_branch_nodes(node)
            if node.comparison_method?
              @condition += 1
            else
              @branch += 1
            end
          end

          def node_has_else_branch?(node)
            %i[case if].include?(node.type) &&
              node.else? &&
              node.loc.else.is?('else')
          end
        end
      end
    end
  end
end
