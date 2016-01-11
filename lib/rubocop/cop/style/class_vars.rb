# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of class variables. Offenses
      # are signaled only on assignment to class variables to
      # reduced the number of offenses that would be reported.
      class ClassVars < Cop
        MSG = 'Replace class var %s with a class instance var.'.freeze

        def on_cvasgn(node)
          add_offense(node, :name)
        end

        def message(node)
          class_var, = *node
          format(MSG, class_var)
        end
      end
    end
  end
end
