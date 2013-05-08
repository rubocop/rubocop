# encoding: utf-8

module Rubocop
  module Cop
    class AlignParameters < Cop
      ERROR_MESSAGE = 'Align the parameters of a method call if they span ' +
        'more than one line.'

      def inspect(file, source, tokens, sexp)
        @file = file
        @tokens = tokens
        @token_indexes = {}
        @tokens.each_with_index { |t, ix| @token_indexes[t.pos] = ix }

        each(:method_add_arg, sexp) do |method_add_arg|
          args = get_args(method_add_arg) or next
          first_arg, rest_of_args = divide_args(args)
          @first_lparen_ix = get_lparen_ix(method_add_arg)
          pos_of_1st_arg = position_of(first_arg) or next # Give up.
          rest_of_args.each do |arg|
            pos = position_of(arg) or next # Give up if no position found.
            if pos.lineno != pos_of_1st_arg.lineno
              if pos.column != pos_of_1st_arg.column
                add_offence(:convention, pos.lineno, ERROR_MESSAGE)
              end
            end
          end
        end
      end

      private

      def get_args(method_add_arg)
        fcall = method_add_arg[1]
        return nil if fcall[0] != :fcall
        return nil if fcall[1][0..1] == [:@ident, 'lambda']
        arg_paren = method_add_arg[2..-1][0]
        return nil if arg_paren[0] != :arg_paren || arg_paren[1].nil?

        # A command (call wihtout parentheses) as first parameter
        # means there's only one parameter.
        return nil if [:command, :command_call].include?(arg_paren[1][0][0])

        if arg_paren[1][0] == :args_add_block
          args_add_block = arg_paren[1]
          args_add_block[1].empty? ? [args_add_block[2]] : args_add_block[1]
        else
          arg_paren[1]
        end
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

      def get_lparen_ix(method_add_arg)
        method_name_pos = method_add_arg[1][1][-1]
        method_name_ix = @token_indexes[method_name_pos]
        method_name_ix +
          @tokens[method_name_ix..-1].map(&:type).index(:on_lparen)
      end

      def position_of(sexp)
        # Indentation inside a string literal is irrelevant.
        return nil if sexp[0] == :string_literal

        pos = find_pos_in_sexp(sexp) or return nil # Nil means not found.
        ix = find_first_non_whitespace_token(pos) or return nil
        @tokens[ix].pos
      end

      def find_pos_in_sexp(sexp)
        return sexp[2] if Position === sexp[2]
        sexp.grep(Array).each do |s|
          pos = find_pos_in_sexp(s) and return pos
        end
        nil
      end

      def find_first_non_whitespace_token(pos)
        ix = @token_indexes[pos]
        newline_found = false
        start_ix = ix.downto(0) do |i|
          case @tokens[i].text
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
        offset = @tokens[start_ix..-1].index { |t| !whitespace?(t) }
        start_ix + offset
      end
    end
  end
end
