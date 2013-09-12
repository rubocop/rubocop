# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the elements of a multi-line array literal are
      # aligned.
      class AlignArray < Cop
        MSG = 'Align the elements of an array literal if they span more ' +
          'than one line.'

        def on_array(node)
          first_element = node.children.first

          node.children.each_cons(2) do |prev, current|
            if current.loc.line != prev.loc.line
              @column_delta = first_element.loc.column - current.loc.column
              if current.loc.column != first_element.loc.column
                convention(current, :expression)
              end
            end
          end
        end

        def autocorrect_action(node)
          # We can't use the instance variable inside the lambda. That would
          # just give each lambda the same reference and they would all get
          # the last value of @column_delta. A local variable fixes the
          # problem.
          column_delta = @column_delta

          @corrections << lambda do |corrector|
            expr = node.loc.expression
            if column_delta > 0
              corrector.replace(expr, ' ' * column_delta + expr.source)
            else
              range = Parser::Source::Range.new(expr.source_buffer,
                                                expr.begin_pos + column_delta,
                                                expr.end_pos)
              corrector.replace(range, expr.source)
            end
          end
        end
      end
    end
  end
end
