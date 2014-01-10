# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of the `then` keyword in multi-line if statements.
      #
      # @example This is considered bad practice:
      #
      #   if cond then
      #   end
      #
      # @example If statements can contain `then` on the same line:
      #
      #   if cond then a
      #   elsif cond then b
      #   end
      class MultilineIfThen < Cop
        include IfNode
        include IfThenElse

        def offending_line(node)
          condition, body, else_clause = *node
          next_thing = if body && body.loc.expression
                         body.loc.expression.begin
                       elsif else_clause && else_clause.loc.expression
                         else_clause.loc.expression.begin
                       else
                         node.loc.end # No body, use "end".
                       end
          right_after_cond =
            Parser::Source::Range.new(next_thing.source_buffer,
                                      end_position(condition),
                                      next_thing.begin_pos)
          if right_after_cond.source =~ /\A\s*then\s*(#.*)?\s*\n/
            node.loc.expression.begin.line
          end
        end

        def end_position(conditional_node)
          conditional_node.loc.expression.end.end_pos
        end

        def error_message(node)
          "Never use then for multi-line #{node.loc.keyword.source}."
        end
      end
    end
  end
end
