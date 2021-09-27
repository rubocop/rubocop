# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the use of local variable names from an outer scope
      # in block arguments or block-local variables. This mirrors the warning
      # given by `ruby -cw` prior to Ruby 2.6:
      # "shadowing outer local variable - foo".
      #
      # NOTE: Shadowing of variables in block passed to `Ractor.new` is allowed
      # because `Ractor` should not access outer variables.
      # eg. following style is encouraged:
      #
      #   worker_id, pipe = env
      #   Ractor.new(worker_id, pipe) do |worker_id, pipe|
      #   end
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

        # @!method ractor_block?(node)
        def_node_matcher :ractor_block?, <<~PATTERN
          (block (send (const nil? :Ractor) :new ...) ...)
        PATTERN

        def self.joining_forces
          VariableForce
        end

        def before_declaring_variable(variable, variable_table)
          return if variable.should_be_unused?
          return if ractor_block?(variable.scope.node)

          outer_local_variable = variable_table.find_variable(variable.name)
          return unless outer_local_variable

          message = format(MSG, variable: variable.name)
          add_offense(variable.declaration_node, message: message)
        end
      end
    end
  end
end
