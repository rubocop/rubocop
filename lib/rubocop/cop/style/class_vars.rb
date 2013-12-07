# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of class variables. Offences
      # are signaled only on assignment to class variables to
      # reduced the number of offences that would be reported.
      class ClassVars < Cop
        MSG = 'Replace class var %s with a class instance var.'

        def on_cvasgn(node)
          add_offence(node, :name)
        end

        def message(node)
          class_var, = *node
          MSG.format(class_var)
        end
      end
    end
  end
end
