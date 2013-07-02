# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Common functionality for cops checking if and unless statements.
      module IfThenElse
        def on_if(node)
          check(node)
          super
        end

        def on_unless(node)
          check(node)
          super
        end

        def check(node)
          # We won't check modifier or ternary conditionals.
          if node.loc.expression.source =~ /\A(if|unless)\b/
            if offending_line(node)
              add_offence(:convention, node.loc.expression, error_message)
            end
          end
        end
      end

      # Checks for uses of semicolon in if statements.
      class IfWithSemicolon < Cop
        include IfThenElse

        def offending_line(node)
          node.loc.begin.line if node.loc.begin && node.loc.begin.is?(';')
        end

        def error_message
          'Never use if x; Use the ternary operator instead.'
        end
      end

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

      # Checks for uses of if/then/else/end on a single line.
      class OneLineConditional < Cop
        include IfThenElse

        def offending_line(node)
          node.loc.expression.line unless node.loc.expression.source =~ /\n/
        end

        def error_message
          'Favor the ternary operator (?:) over if/then/else/end constructs.'
        end
      end
    end
  end
end
