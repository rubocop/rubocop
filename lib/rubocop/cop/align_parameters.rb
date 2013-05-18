# encoding: utf-8

module Rubocop
  module Cop
    class AlignParameters < Cop
      MSG = 'Align the parameters of a method call if they span ' +
        'more than one line.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp) do |node|
          _receiver, method, *args = *node

          next if method == :[]=
          next unless args.size > 1

          first_arg_col = args.first.src.expression.column
          prev_arg_line = args.first.src.expression.line
          prev_arg_col = args.first.src.expression.column

          args.each do |arg|
            cur_arg_line = arg.src.expression.line
            cur_arg_col = arg.src.expression.column

            if cur_arg_line != prev_arg_line &&
                cur_arg_col != first_arg_col
              add_offence(:convetion,
                          cur_arg_line,
                          MSG)
            end

            prev_arg_col = cur_arg_col
            prev_arg_line = cur_arg_line
          end
        end
      end
    end
  end
end
