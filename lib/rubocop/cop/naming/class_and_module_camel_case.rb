# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop checks for class and module names with
      # an underscore in them.
      #
      # @example
      #   # bad
      #   class My_Class
      #   end
      #   module My_Module
      #   end
      #
      #   # good
      #   class MyClass
      #   end
      #   module MyModule
      #   end
      class ClassAndModuleCamelCase < Cop
        MSG = 'Use CamelCase for classes and modules.'

        def on_class(node)
          return unless node.loc.name.source =~ /_/

          add_offense(node, location: :name)
        end
        alias on_module on_class
      end
    end
  end
end
