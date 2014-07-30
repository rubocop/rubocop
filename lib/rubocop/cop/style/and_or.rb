# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of *and* and *or*.
      class AndOr < Cop
        include AutocorrectUnlessChangingAST
        include ConfigurableEnforcedStyle

        MSG = 'Use `%s` instead of `%s`.'

        OPS = { 'and' => '&&', 'or' => '||' }

        def on_and(node)
          process_logical_op(node) if style == :always
        end

        def on_or(node)
          process_logical_op(node) if style == :always
        end

        def on_if(node)
          on_conditionals(node) if style == :conditionals
        end

        def on_while(node)
          on_conditionals(node) if style == :conditionals
        end

        def on_until(node)
          on_conditionals(node) if style == :conditionals
        end

        private

        def on_conditionals(node)
          on_node([:and, :or], node) do |my_node|
            process_logical_op(my_node)
          end
        end

        def process_logical_op(node)
          op = node.loc.operator.source
          op_type = node.type.to_s
          return unless op == op_type

          add_offense(node, :operator, format(MSG, OPS[op], op))
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
