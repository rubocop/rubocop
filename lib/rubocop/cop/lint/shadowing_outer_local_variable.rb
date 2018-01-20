# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop looks for use of the same name as outer local variables
      # for block arguments or block local variables.
      # This is a mimic of the warning
      # "shadowing outer local variable - foo" from `ruby -cw`.
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
      class ShadowingOuterLocalVariable < Cop
        MSG = 'Shadowing outer local variable - `%<variable>s`.'.freeze

        def join_force?(force_class)
          force_class == VariableForce
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
