# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of class variables. Offenses
      # are signaled only on assignment to class variables to
      # reduced the number of offenses that would be reported.
      class ClassVars < Cop
        MSG = 'Replace class var %s with a class instance var.'
        private_constant :MSG

        def on_cvasgn(node)
          class_var, = *node
          add_offense(node, :name, format(MSG, class_var))
        end
      end
    end
  end
end
