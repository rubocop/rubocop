# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of the class/module name instead of
      # self, when defining class/module methods.
      class ClassMethods < Cop
        MSG = 'Prefer self over class/module for class/module methods.'

        # TODO - check if we're in a class/module
        def on_defs(node)
          definee, _name, _args, _body = *node

          if definee.type == :const
            add_offence(:convention, definee.loc.name, MSG)
          end
        end
      end
    end
  end
end
