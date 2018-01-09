# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of class variables. Offenses
      # are signaled only on assignment to class variables to
      # reduce the number of offenses that would be reported.
      #
      # Setting value for class variable need to take care.
      # If some class has been inherited by other classes, setting value
      # for class variable affected children classes.
      # So using class instance variable is better in almost case.
      #
      # @example
      #   # bad
      #   class A
      #     @@test = 10
      #   end
      #
      #   # good
      #   class A
      #     @test = 10
      #   end
      #
      #   class A
      #     def test
      #       @@test # you can access class variable without offence
      #     end
      #   end
      #
      class ClassVars < Cop
        MSG = 'Replace class var %<class_var>s with a class ' \
              'instance var.'.freeze

        def on_cvasgn(node)
          add_offense(node, location: :name)
        end

        def message(node)
          class_var, = *node
          format(MSG, class_var: class_var)
        end
      end
    end
  end
end
