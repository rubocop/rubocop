# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of the class/module name instead of
      # self, when defining class/module methods.
      class ClassMethods < Cop
        MSG = 'Use `self.%s` instead of `%s.%s`.'

        # TODO: Check if we're in a class/module
        def on_defs(node)
          definee, method_name, _args, _body = *node

          if definee.type == :const
            _, class_name = *definee
            add_offense(definee, :name,
                        message(class_name, method_name))
          end
        end

        private

        def message(class_name, method_name)
          format(MSG, method_name, class_name, method_name)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.name, 'self')
          end
        end
      end
    end
  end
end
