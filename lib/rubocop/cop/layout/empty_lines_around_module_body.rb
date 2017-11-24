# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cops checks if empty lines around the bodies of modules match
      # the configuration.
      #
      # @example EnforcedStyle: empty_lines
      #   # good
      #
      #   module Foo
      #
      #     def bar
      #       # ...
      #     end
      #
      #   end
      #
      # @example EnforcedStyle: no_empty_lines (default)
      #   # good
      #
      #   module Foo
      #     def bar
      #       # ...
      #     end
      #   end
      class EmptyLinesAroundModuleBody < Cop
        include EmptyLinesAroundBody

        KIND = 'module'.freeze

        def on_module(node)
          _name, body = *node
          check(node, body)
        end
      end
    end
  end
end
