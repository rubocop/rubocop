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
      class SymbolLiteral < Cop
        MSG = 'Do not use strings for word-like symbol literals.'.freeze

        def on_sym(node)
          return unless node.source =~ /\A:["'][A-Za-z_]\w*["']\z/

          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, node.source.delete(%q('")))
          end
        end
      end
    end
  end
end
