# encoding: utf-8

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
        MSG = 'Do not use strings for word-like symbol literals.'

        def on_sym(node)
          sym_name = node.loc.expression.source

          return unless sym_name =~ /\A:["'][A-Za-z_]\w*["']\z/

          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            current_name = node.loc.expression.source
            corrector.replace(node.loc.expression,
                              current_name.gsub(/["']/, ''))
          end
        end
      end
    end
  end
end
