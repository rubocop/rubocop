# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses if the keyword *not* instead of !.
      class Not < Cop
        include AutocorrectUnlessChangingAST

        MSG = 'Use `!` instead of `not`.'

        def on_send(node)
          _receiver, method_name, *args = *node

          # not does not take any arguments
          if args.empty? && method_name == :! &&
              node.loc.selector.is?('not')
            add_offense(node, :selector)
          end
        end

        private

        def correction(node)
          lambda do |corrector|
            old_source = node.loc.expression.source
            new_source = old_source.sub(/not\s+/, '!')
            corrector.replace(node.loc.expression, new_source)
          end
        end
      end
    end
  end
end
