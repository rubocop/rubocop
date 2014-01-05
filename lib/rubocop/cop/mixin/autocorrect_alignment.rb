# encoding: utf-8

module Rubocop
  module Cop
    # This module does auto-correction of nodes that should just be moved to
    # the left or to the right, amount being determined by the instance
    # variable @column_delta.
    module AutocorrectAlignment
      def check_alignment(items)
        items.each_cons(2) do |prev, current|
          if current.loc.line > prev.loc.line && start_of_line?(current.loc)
            @column_delta = items.first.loc.column - current.loc.column
            add_offence(current, :expression) if @column_delta != 0
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
          each_line(expr) do |line_begin_pos, line|
            range = calculate_range(expr, line_begin_pos, column_delta)
            if column_delta > 0
              corrector.insert_before(range, ' ' * column_delta)
            else
              remove(range, corrector)
            end
          end
        end
      end

      def calculate_range(expr, line_begin_pos, column_delta)
        starts_with_space = expr.source_buffer.source[line_begin_pos] =~ / /
        pos_to_remove = if column_delta > 0 || starts_with_space
                          line_begin_pos
                        else
                          line_begin_pos - column_delta.abs
                        end
        Parser::Source::Range.new(expr.source_buffer, pos_to_remove,
                                  pos_to_remove + column_delta.abs)
      end

      def remove(range, corrector)
        original_stderr = $stderr
        $stderr = StringIO.new # Avoid error messages on console
        corrector.remove(range)
      rescue RuntimeError
        range = Parser::Source::Range.new(range.source_buffer,
                                          range.begin_pos + 1,
                                          range.end_pos + 1)
        retry if range.source =~ /^ +$/
      ensure
        $stderr = original_stderr
      end

      def each_line(expr)
        offset = 0
        expr.source.each_line do |line|
          line_begin_pos = expr.begin_pos + offset
          yield line_begin_pos, line
          offset += line.length
        end
      end
    end
  end
end
