# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of the `then` keyword in multi-line if statements.
      #
      # This is considered bad practice:
      # @example
      #
      # if cond then
      # end
      #
      # While if statements can contain `then` on the same line:
      # @example
      #
      # if cond then a
      # elsif cond then b
      # end
      class MultilineIfThen < Cop
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
                                      condition.loc.expression.end.end_pos,
                                      next_thing.begin_pos)
          if right_after_cond.source =~ /\A\s*then\s*(#.*)?\s*\n/
            node.loc.expression.begin.line
          end
        end

        def error_message
          'Never use then for multi-line if/unless.'
        end
      end
    end
  end
end
