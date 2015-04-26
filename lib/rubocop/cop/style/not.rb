# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses if the keyword *not* instead of !.
      class Not < Cop
        include AutocorrectUnlessChangingAST

        MSG = 'Use `!` instead of `not`.'

        def on_send(node)
          _receiver, method_name, *args = *node

          # not does not take any arguments
          return unless args.empty? && method_name == :! &&
                        node.loc.selector.is?('not')

          add_offense(node, :selector)
        end

        private

        def correction(node)
          old_source = node.loc.expression.source
          new_source = old_source.sub(/not\s+/, '!')
          ->(corrector) { corrector.replace(node.loc.expression, new_source) }
        end
      end
    end
  end
end
