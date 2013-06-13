# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class ClassMethods < Cop
        MSG = 'Prefer self over class/module for class/module methods.'

        def on_defs(node)
          definee, _name, _args, _body = *node

          if definee.type == :const
            add_offence(:convention, node.loc.expression, MSG)
          end
        end
      end
    end
  end
end
