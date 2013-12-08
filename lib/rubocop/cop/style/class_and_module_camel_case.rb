# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for class and module names with
      # an underscore in them.
      class ClassAndModuleCamelCase < Cop
        MSG = 'Use CamelCase for classes and modules.'

        def on_class(node)
          check_name(node)
        end

        def on_module(node)
          check_name(node)
        end

        private

        def check_name(node)
          name = node.loc.name.source

          add_offence(node, :name) if name =~ /_/
        end
      end
    end
  end
end
