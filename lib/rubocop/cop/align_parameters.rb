# encoding: utf-8

module Rubocop
  module Cop
    class AlignParameters < Cop
      MSG = 'Align the parameters of a method call if they span ' +
        'more than one line.'

      def on_send(node)
        _receiver, method, *args = *node

        if method != :[]= && args.size > 1
          first_arg_col = args.first.loc.expression.column
          prev_arg_line = args.first.loc.expression.line
          prev_arg_col = first_arg_col

          args.each do |arg|
            cur_arg_line = arg.loc.expression.line
            cur_arg_col = arg.loc.expression.column

            if cur_arg_line != prev_arg_line &&
                cur_arg_col != first_arg_col
              add_offence(:convention, arg.loc.expression, MSG)
            end

            prev_arg_col = cur_arg_col
            prev_arg_line = cur_arg_line
          end
        end

        super
      end
    end
  end
end
