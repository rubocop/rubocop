# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cops checks for class and module names with
      # an underscore in them.
      class ClassAndModuleCamelCase < Cop
        MSG = 'Use CamelCase for classes and modules.'.freeze

        def on_class(node)
          check_name(node)
        end

        def on_module(node)
          check_name(node)
        end

        private

        def check_name(node)
          name = node.loc.name.source

          add_offense(node, location: :name) if name =~ /_/
        end
      end
    end
  end
end
