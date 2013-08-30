# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the parameters on a multi-line method call are
      # aligned.
      class AlignParameters < Cop
        MSG = 'Align the parameters of a method call if they span ' +
          'more than one line.'

        def on_send(node)
          _receiver, method, *args = *node

          return if method == :[]=
          return if args.size <= 1

          first_arg_column = args.first.loc.expression.column

          args.each_cons(2) do |prev, current|
            current_pos = current.loc.expression

            if current_pos.line > prev.loc.expression.line &&
                current_pos.column != first_arg_column
              convention(nil, current_pos)
              # do_autocorrect(current, first_arg_column - current_pos.column)
            end
          end
        end

        # def autocorrect_action(node, column_delta)
        #   @corrections << lambda do |corrector|
        #     expr = node.loc.expression
        #     if column_delta > 0
        #       corrector.replace(expr, ' ' * column_delta + expr.source)
        #     else
        #       range = Parser::Source::Range.new(expr.source_buffer,
        #                                         expr.begin_pos+column_delta,
        #                                         expr.end_pos)
        #       corrector.replace(range, expr.source)
        #     end
        #   end
        # end
      end
    end
  end
end
