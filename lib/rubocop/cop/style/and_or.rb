# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of *and* and *or*.
      class AndOr < Cop
        MSG = 'Use %s instead of %s.'

        OPS = { 'and' => '&&', 'or' => '||' }

        def on_and(node)
          process_logical_op(node)
        end

        def on_or(node)
          process_logical_op(node)
        end

        private

        def process_logical_op(node)
          op = node.loc.operator.source
          op_type = node.type.to_s

          if op == op_type
            add_offence(node,
                        :operator,
                        sprintf(MSG, OPS[op], op))
          end
        end

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
            replacement = (node.type == :and ? '&&' : '||')
            corrector.replace(node.loc.operator, replacement)
          end
        end
      end
    end
  end
end
