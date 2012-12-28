# encoding: utf-8

require_relative 'grammar'

module Rubocop
  module Cop
    class AlignParameters < Cop
      ERROR_MESSAGE = 'Align the parameters of a method call if they span ' +
        'more than one line.'

      def inspect(file, source, tokens, sexp)
        @file = file
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
            if pos[0] != pos_of_1st_arg[0] && pos[1] != pos_of_1st_arg[1]
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
        return nil if arg_paren[0] != :arg_paren || arg_paren[1].nil?

        # A command (call wihtout parentheses) as first parameter
        # means there's only one parameter.
        return nil if [:command, :command_call].include?(arg_paren[1][0][0])

        args_add_block = arg_paren[1]
        unless args_add_block[0] == :args_add_block
          fail "\n#{@file}: #{method_add_arg}"
        end
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
        # Indentation inside a string literal is irrelevant.
        return nil if sexp[0] == :string_literal

        pos = find_pos_in_sexp(sexp) or return nil # Nil means not found.
        ix = find_first_non_whitespace_token(pos) or return nil
        @tokens[ix][0]
      end

      def find_pos_in_sexp(sexp)
        return sexp[2] if Array === sexp[2] && Fixnum === sexp[2][0]
        sexp.grep(Array).each do |s|
          pos = find_pos_in_sexp(s) and return pos
        end
        nil
      end

      def find_first_non_whitespace_token(pos)
        ix = @tokens.index { |t| t[0] == pos }
        newline_found = false
        start_ix = ix.downto(0) do |i|
          case @tokens[i][2]
          when '('
            break i + 1 if i == @first_lparen_ix
          when "\n"
            newline_found = true
          when /\t/
            # Bail out if tabs are used. Too difficult to calculate column.
            return nil
          when ','
            if newline_found
              break i + 1
            else
              # Bail out if there's a preceding comma on the same line.
              return nil
            end
          end
        end
        offset = @tokens[start_ix..-1].index { |t| not whitespace?(t) }
        start_ix + offset
      end
    end
  end
end
