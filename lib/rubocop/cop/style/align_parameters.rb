# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the parameters on a multi-line method call are
      # aligned.
      class AlignParameters < Cop
        include AutocorrectAlignment

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
              @column_delta = first_arg_column - current_pos.column
              convention(current, current_pos)
            end
          end
        end
      end
    end
  end
end
