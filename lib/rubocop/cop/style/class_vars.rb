# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of class variables. Offenses
      # are signaled only on assignment to class variables to
      # reduce the number of offenses that would be reported.
      #
      # You have to be careful when setting a value for a class
      # variable; if a class has been inherited, changing the
      # value of a class variable also affects the inheriting
      # classes. This means that it's almost always better to
      # use a class instance variable instead.
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
      #       @@test # you can access class variable without offense
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
