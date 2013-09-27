# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This module does auto-correction of nodes that should just be moved to
      # the left or to the right, amount being determined by the instance
      # variable @column_delta.
      module AutocorrectAlignment
        def check_alignment(items)
          items.each_cons(2) do |prev, current|
            if current.loc.line > prev.loc.line && start_of_line?(current.loc)
              @column_delta = items.first.loc.column - current.loc.column
              convention(current, :expression) if @column_delta != 0
            end
          end
        end

        def start_of_line?(loc)
          loc.expression.source_line[0...loc.column] =~ /^\s*$/
        end

        def autocorrect(node)
          # We can't use the instance variable inside the lambda. That would
          # just give each lambda the same reference and they would all get
          # the last value of @column_delta. A local variable fixes the
          # problem.
          column_delta = @column_delta

          @corrections << lambda do |corrector|
            expr = node.loc.expression
            if column_delta > 0
              corrector.replace(expr,
                                expr.source.gsub(/^/, ' ' * column_delta))
            else
              offset = 0
              expr.source.each_line do |line|
                b = expr.begin_pos + offset
                if offset == 0
                  range = Parser::Source::Range.new(expr.source_buffer,
                                                    b + column_delta,
                                                    b + line.length)
                  corrector.replace(range, line)
                else
                  range = Parser::Source::Range.new(expr.source_buffer,
                                                    b, b + line.length)
                  corrector.replace(range, line[-column_delta..-1])
                end
                offset += line.length
              end
            end
          end
        end
      end
    end
  end
end
