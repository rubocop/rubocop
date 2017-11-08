# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for `:true` and `:false` symbols.
      # In most cases it would be a typo.
      #
      # @example
      #
      #   # bad
      #   :true
      #
      #   # good
      #   true
      #
      # @example
      #
      #   # bad
      #   :false
      #
      #   # good
      #   false
      class BooleanSymbol < Cop
        MSG = 'Symbol with a boolean name - ' \
              'you probably meant to use `%s`.'.freeze

        def_node_matcher :boolean_symbol?, '(sym {:true :false})'

        def on_sym(node)
          return unless boolean_symbol?(node)

          add_offense(node, message: format(MSG, node.value))
        end
      end
    end
  end
end
