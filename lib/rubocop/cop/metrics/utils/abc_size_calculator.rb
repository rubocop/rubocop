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
          include IteratingBlock
          include RepeatedCsendDiscount

          # > Branch -- an explicit forward program branch out of scope -- a
          # > function call, class method call ..
          # > http://c2.com/cgi/wiki?AbcMetric
          BRANCH_NODES = %i[send csend yield].freeze

          # > Condition -- a logical/Boolean test, == != <= >= < > else case
          # > default try catch ? and unary conditionals.
          # > http://c2.com/cgi/wiki?AbcMetric
          CONDITION_NODES = CyclomaticComplexity::COUNTED_NODES.freeze

          def self.calculate(node)
            new(node).calculate
          end

          # TODO: move to rubocop-ast
          ARGUMENT_TYPES = %i[arg optarg restarg kwarg kwoptarg kwrestarg blockarg].freeze

          private_constant :BRANCH_NODES, :CONDITION_NODES, :ARGUMENT_TYPES

          def initialize(node)
            @assignment = 0
            @branch = 0
            @condition = 0
            @node = node
            reset_repeated_csend
          end

          def calculate
            @node.each_node do |child|
              @assignment += 1 if assignment?(child)

              if branch?(child)
                evaluate_branch_nodes(child)
              elsif condition?(child)
                evaluate_condition_node(child)
              end
            end

            [
              Math.sqrt(@assignment**2 + @branch**2 + @condition**2).round(2),
              "<#{@assignment}, #{@branch}, #{@condition}>"
            ]
          end

          def evaluate_branch_nodes(node)
            if node.comparison_method?
              @condition += 1
            else
              @branch += 1
              @condition += 1 if node.csend_type? && !discount_for_repeated_csend?(node)
            end
          end

          def evaluate_condition_node(node)
            @condition += 1 if else_branch?(node)
            @condition += 1
          end

          def else_branch?(node)
            %i[case if].include?(node.type) &&
              node.else? &&
              node.loc.else.is?('else')
          end

          private

          def assignment?(node)
            return compound_assignment(node) if node.masgn_type? || node.shorthand_asgn?

            node.for_type? ||
              (node.respond_to?(:setter_method?) && node.setter_method?) ||
              simple_assignment?(node) ||
              argument?(node)
          end

          def compound_assignment(node)
            # Methods setter can not be detected for multiple assignments
            # and shorthand assigns, so we'll count them here instead
            children = node.masgn_type? ? node.children[0].children : node.children

            will_be_miscounted = children.count do |child|
              child.respond_to?(:setter_method?) &&
                !child.setter_method?
            end
            @assignment += will_be_miscounted

            false
          end

          def simple_assignment?(node)
            if !node.equals_asgn?
              false
            elsif node.lvasgn_type?
              reset_on_lvasgn(node)
              capturing_variable?(node.children.first)
            else
              true
            end
          end

          def capturing_variable?(name)
            name && !/^_/.match?(name)
          end

          def branch?(node)
            BRANCH_NODES.include?(node.type)
          end

          def argument?(node)
            ARGUMENT_TYPES.include?(node.type) && capturing_variable?(node.children.first)
          end

          def condition?(node)
            return false if iterating_block?(node) == false

            CONDITION_NODES.include?(node.type)
          end
        end
      end
    end
  end
end
