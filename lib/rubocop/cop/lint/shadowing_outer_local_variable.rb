# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the use of local variable names from an outer scope
      # in block arguments or block-local variables. This mirrors the warning
      # given by `ruby -cw` prior to Ruby 2.6:
      # "shadowing outer local variable - foo".
      #
      # @example
      #
      #   # bad
      #
      #   def some_method
      #     foo = 1
      #
      #     2.times do |foo| # shadowing outer `foo`
      #       do_something(foo)
      #     end
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method
      #     foo = 1
      #
      #     2.times do |bar|
      #       do_something(bar)
      #     end
      #   end
      class ShadowingOuterLocalVariable < Base
        MSG = 'Shadowing outer local variable - `%<variable>s`.'

        def self.joining_forces
          VariableForce
        end

        def before_declaring_variable(variable, variable_table)
          return if variable.should_be_unused?

          outer_local_variable = variable_table.find_variable(variable.name)
          return unless outer_local_variable

          message = format(MSG, variable: variable.name)
          add_offense(variable.declaration_node, message: message)
        end
      end
    end
  end
end
