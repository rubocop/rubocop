# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that all numbered variables use the
      # configured style, snake_case, normalcase or non_integer,
      # for their numbering.
      #
      # @example
      #   "EnforcedStyle => 'snake_case'"
      #
      #   # bad
      #
      #   variable1 = 1
      #
      #   # good
      #
      #   variable_1 = 1
      #
      # @example
      #   "EnforcedStyle => 'normalcase'"
      #
      #   # bad
      #
      #   variable_1 = 1
      #
      #   # good
      #
      #   variable1 = 1
      #
      # @example
      #   "EnforcedStyle => 'non_integer'"
      #
      #   #bad
      #
      #   variable1 = 1
      #
      #   variable_1 = 1
      #
      #   #good
      #
      #   variableone = 1
      #
      #   variable_one = 1
      #
      class VariableNumber < Cop
        include ConfigurableNumbering

        def on_lvasgn(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        def on_ivasgn(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        def on_cvasgn(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        def on_arg(node)
          name, = *node
          check_name(node, name, node.loc.name)
        end

        private

        def message(style)
          format('Use %s for variable numbers.', style)
        end
      end
    end
  end
end
