# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks symbol literal syntax.
      #
      # @example
      #
      #   # bad
      #   :"symbol"
      #
      #   # good
      #   :symbol
      class SymbolLiteral < Base
        extend AutoCorrector

        MSG = 'Do not use strings for word-like symbol literals.'

        def on_sym(node)
          return unless /\A:["'][A-Za-z_]\w*["']\z/.match?(node.source)

          add_offense(node) { |corrector| corrector.replace(node, node.source.delete(%q('"))) }
        end
      end
    end
  end
end
