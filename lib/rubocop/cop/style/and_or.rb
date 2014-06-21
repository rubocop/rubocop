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

        def on_while_post(node)
          on_conditionals(node) if style == :conditionals
        end

        def on_until(node)
          on_conditionals(node) if style == :conditionals
        end

        def on_until_post(node)
          on_conditionals(node) if style == :conditionals
        end

        private

        def on_conditionals(node)
          condition_node, = *node

          condition_node.each_node(:and, :or) do |logical_node|
            process_logical_op(logical_node)
          end
        end

        def process_logical_op(node)
          op = node.loc.operator.source
          op_type = node.type.to_s
          return unless op == op_type

          add_offense(node, :operator, format(MSG, OPS[op], op))
        end

        def correction(node)
          expr1, expr2 = *node
          replacement = (node.type == :and ? '&&' : '||')
          lambda do |corrector|
            [expr1, expr2].each do |expr|
              _receiver, _method_name, *args = *expr
              next unless correctable?(expr)

              sb = expr.loc.expression.source_buffer
              begin_paren = expr.loc.selector.end_pos
              end_paren = begin_paren + 1
              range = Parser::Source::Range.new(sb, begin_paren, end_paren)
              corrector.replace(range, '(')
              corrector.insert_after(args.last.loc.expression, ')')
            end
            corrector.replace(node.loc.operator, replacement)
          end
        end

        def correctable?(expr)
          return false unless expr.type == :send
          _receiver, method_name, *args = *expr
          # don't clobber if we already have a starting paren
          return false unless !expr.loc.begin || expr.loc.begin.source != '('
          # don't touch anything unless we are sure it is a method call.
          return false unless args.last && method_name.to_s =~ /[a-z]/

          true
        end
      end
    end
  end
end
