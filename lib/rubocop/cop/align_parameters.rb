# encoding: utf-8

require_relative 'grammar'

module Rubocop
  module Cop
    class AlignParameters < Cop
      ERROR_MESSAGE = 'Align the parameters of a method call if they span ' +
        'more than one line.'

      def inspect(file, source, tokens, sexp)
        @tokens = tokens
        each(:method_add_arg, sexp) do |method_add_arg|
          args = get_args(method_add_arg) or next
          first_arg, rest_of_args = divide_args(args)
          method_name_pos = method_add_arg[1][1][-1]
          method_name_ix = @tokens.index { |t| t[0] == method_name_pos }
          @first_lparen_ix = method_name_ix +
            @tokens[method_name_ix..-1].index { |t| t[1] == :on_lparen }
          pos_of_1st_arg = position_of(first_arg) or next # Give up.
          rest_of_args.each do |arg|
            pos = position_of(arg) or next # Give up if no position found.
            if pos[1] != pos_of_1st_arg[1]
              index = pos[0] - 1
              add_offence(:convention, index, source[index], ERROR_MESSAGE)
            end
          end
        end
      end

      def get_args(method_add_arg)
        fcall = method_add_arg[1]
        return nil if fcall[0] != :fcall
        return nil if fcall[1][0..1] == [:@ident, "lambda"]
        arg_paren = method_add_arg[2..-1][0]
        return nil if arg_paren[0] != :arg_paren
        args_add_block = arg_paren[1]
        fail unless args_add_block[0] == :args_add_block
        args_add_block[1].empty? ? [args_add_block[2]] : args_add_block[1]
      end

      def divide_args(args)
        if args[0] == :args_add_star
          first_arg = args[1]
          rest_of_args = args[2..-1]
        else
          first_arg = args[0]
          rest_of_args = args[1..-1]
        end
        [first_arg, rest_of_args]
      end

      def position_of(sexp)
        pos = find_pos_in_sexp(sexp) or return nil # Nil means not found.
        ix = @tokens.index { |t| t[0] == pos }
        start_ix = ix.downto(0) do |i|
          break i + 1 if @tokens[i][2] == "\n" || i == @first_lparen_ix
        end
        offset = @tokens[start_ix..-1].index { |t| not whitespace?(t) }
        @tokens[start_ix + offset][0]
      end

      def find_pos_in_sexp(sexp)
        if Array === sexp[2] && Fixnum === sexp[2][0]
          # :@tstring_content can indicate a heredoc and indentation
          # there is irrelevant.
          return sexp[2] unless sexp[0] == :@tstring_content
        end
        sexp.grep(Array).each do |s|
          pos = find_pos_in_sexp(s) and return pos
        end
        nil
      end
    end
  end
end
