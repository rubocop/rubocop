# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that all methods use the configured style,
      # snake_case or camelCase, for their names.
      #
      # @example EnforcedStyle: snake_case (default)
      #   # bad
      #   def fooBar; end
      #
      #   # good
      #   def foo_bar; end
      #
      # @example EnforcedStyle: camelCase
      #   # bad
      #   def foo_bar; end
      #
      #   # good
      #   def fooBar; end
      class MethodName < Cop
        include ConfigurableNaming

        MSG = 'Use %<style>s for method names.'.freeze

        def on_def(node)
          return if node.operator_method?

          check_name(node, node.method_name, node.loc.name)
        end
        alias on_defs on_def

        private

        def message(style)
          format(MSG, style: style)
        end
      end
    end
  end
end
