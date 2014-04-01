# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses if the keyword *not* instead of !.
      class Not < Cop
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

        def autocorrect(node)
          c = correction(node)
          new_source = rewrite_node(node, c)

          # Make the correction only if it doesn't change the AST.
          @corrections << c if node == SourceParser.parse(new_source).ast
        end

        def rewrite_node(node, correction)
          processed_source = SourceParser.parse(node.loc.expression.source)
          c = correction(processed_source.ast)
          Corrector.new(processed_source.buffer, [c]).rewrite
        end

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
