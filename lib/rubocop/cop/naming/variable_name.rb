# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that all variables use the configured style,
      # snake_case or camelCase, for their names.
      #
      # @example EnforcedStyle: snake_case (default)
      #   # bad
      #   fooBar = 1
      #
      #   # good
      #   foo_bar = 1
      #
      # @example EnforcedStyle: camelCase
      #   # bad
      #   foo_bar = 1
      #
      #   # good
      #   fooBar = 1
      class VariableName < Cop
        include ConfigurableNaming

        MSG = 'Use %<style>s for variable names.'

        def on_lvasgn(node)
          name, = *node
          return unless name

          check_name(node, name, node.loc.name)
        end
        alias on_ivasgn    on_lvasgn
        alias on_cvasgn    on_lvasgn
        alias on_arg       on_lvasgn
        alias on_optarg    on_lvasgn
        alias on_restarg   on_lvasgn
        alias on_kwoptarg  on_lvasgn
        alias on_kwarg     on_lvasgn
        alias on_kwrestarg on_lvasgn
        alias on_blockarg  on_lvasgn
        alias on_lvar      on_lvasgn

        private

        def message(style)
          format(MSG, style: style)
        end
      end
    end
  end
end
