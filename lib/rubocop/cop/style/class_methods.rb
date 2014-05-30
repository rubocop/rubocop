# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the class/module name instead of
      # self, when defining class/module methods.
      class ClassMethods < Cop
        MSG = 'Use `self.%s` instead of `%s.%s`.'

        def on_class(node)
          _name, _superclass, body = *node
          check(body)
        end

        def on_module(node)
          _name, body = *node
          check(body)
        end

        private

        def check(node)
          return unless node

          if node.type == :defs
            check_defs(node)
          elsif node.type == :begin
            defs_nodes = node.children.compact.select { |n| n.type == :defs }
            defs_nodes.each { |n| check_defs(n) }
          end
        end

        def check_defs(node)
          definee, method_name, _args, _body = *node
          return unless definee.type == :const

          _, class_name = *definee
          add_offense(definee, :name, message(class_name, method_name))
        end

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
