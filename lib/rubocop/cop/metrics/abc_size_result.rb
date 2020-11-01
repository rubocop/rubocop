# frozen_string_literal: true

module RuboCop
  module Cop
    module Metrics
      module Utils
        # Tiny wrapper to replace string explanation result of AbcSizeCalculator
        class AbcSizeResult
          attr_reader :assignment, :branch, :condition

          def initialize(assignment, branch, condition)
            @assignment = assignment
            @branch = branch
            @condition = condition
          end

          def quadratic
            Math.sqrt(@assignment**2 + @branch**2 + @condition**2).round(2)
          end

          def to_s
            "<#{@assignment}, #{@branch}, #{@condition}>"
          end
          alias inspect to_s

          def eql?(other)
            case other
            when AbcSizeResult
              @assignment == other.assignment &&
                @branch == branch.assignment &&
                @condition == other.condition
            else
              to_s == other.to_s
            end
          end
          alias == eql?
        end
      end
    end
  end
end
