# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of *and* and *or*.
      class AndOr < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `%s` instead of `%s`.'.freeze

        OPS = { 'and' => '&&', 'or' => '||' }.freeze

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

        def autocorrect(node)
          expr1, expr2 = *node
          replacement = (node.type == :and ? '&&' : '||')
          lambda do |corrector|
            [expr1, expr2].each do |expr|
              if expr.send_type?
                correct_send(expr, corrector)
              elsif expr.return_type?
                correct_other(expr, corrector)
              elsif expr.assignment?
                correct_other(expr, corrector)
              end
            end
            corrector.replace(node.loc.operator, replacement)
          end
        end

        def correct_send(node, corrector)
          receiver, method_name, *args = *node
          if method_name == :!
            # ! is a special case:
            # 'x and !obj.method arg' can be auto-corrected if we
            # recurse down a level and add parens to 'obj.method arg'
            # however, 'not x' also parses as (send x :!)

            if node.loc.selector.source == '!'
              node = receiver
              return unless node.send_type?
              _receiver, _method_name, *args = *node
            elsif node.loc.selector.source == 'not'
              return correct_other(node, corrector)
            else
              raise 'unrecognized unary negation operator'
            end
          end
          return unless correctable_send?(node)

          sb = node.source_range.source_buffer
          begin_paren = node.loc.selector.end_pos
          range = Parser::Source::Range.new(sb, begin_paren, begin_paren + 1)
          corrector.replace(range, '(')
          corrector.insert_after(args.last.source_range, ')')
        end

        def correct_other(node, corrector)
          return unless node.source_range.begin.source != '('
          corrector.insert_before(node.source_range, '(')
          corrector.insert_after(node.source_range, ')')
        end

        def correctable_send?(node)
          _receiver, method_name, *args = *node
          # don't clobber if we already have a starting paren
          return false unless !node.loc.begin || node.loc.begin.source != '('
          # don't touch anything unless we are sure it is a method call.
          return false unless args.last && method_name.to_s =~ /[a-z]/

          true
        end
      end
    end
  end
end
