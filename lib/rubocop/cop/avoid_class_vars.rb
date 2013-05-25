# encoding: utf-8

module Rubocop
  module Cop
    class AvoidClassVars < Cop
      MSG = 'Replace class var %s with a class instance var.'

      def on_cvasgn(node)
        class_var, = *node
        add_offence(:convention, node.loc.name.line, sprintf(MSG, class_var))
        super
      end
    end
  end
end
