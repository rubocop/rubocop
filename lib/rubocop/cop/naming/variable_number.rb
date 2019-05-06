# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that all numbered variables use the
      # configured style, snake_case, normalcase, or non_integer,
      # for their numbering.
      #
      # @example EnforcedStyle: snake_case
      #   # bad
      #
      #   variable1 = 1
      #
      #   # good
      #
      #   variable_1 = 1
      #
      # @example EnforcedStyle: normalcase (default)
      #   # bad
      #
      #   variable_1 = 1
      #
      #   # good
      #
      #   variable1 = 1
      #
      # @example EnforcedStyle: non_integer
      #   # bad
      #
      #   variable1 = 1
      #
      #   variable_1 = 1
      #
      #   # good
      #
      #   variableone = 1
      #
      #   variable_one = 1
      class VariableNumber < Cop
        include ConfigurableNumbering

        MSG = 'Use %<style>s for variable numbers.'

        def on_arg(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end
        alias on_lvasgn on_arg
        alias on_ivasgn on_arg
        alias on_cvasgn on_arg

        private

        def message(style)
          format(MSG, style: style)
        end
      end
    end
  end
end
