# encoding: utf-8

require_relative 'grammar'

module Rubocop
  module Cop
    class AlignParameters < Cop
      ERROR_MESSAGE = 'Align the parameters of a method call if they span ' +
        'more than one line.'

      MATCHING_PAREN = {
        ')'   => '(',
        '}'   => '{',
        ']'   => '[',
        'end' => 'do'
      }

      def inspect(file, source, tokens, sexp)
        each(:method_add_arg, sexp) do |s|
          next if s[1][0] != :fcall
          next if s[1][1][0..1] == [:@ident, "lambda"]
          next if s[2..-1][0][0] != :arg_paren
          method_name_ix = tokens.map { |t| t[0] }.index(s[1][1][-1])
          state = :waiting_for_lparen
          @paren_stack = []
          @inside_string = false
          tokens[method_name_ix..-1].each_with_index do |t, i|
            break if t[1] == :on_rparen && @paren_stack.size == 1
            state = process_token(t, i, state, source)
          end
        end
      end

      def process_token(t, i, state, source)
        case state
        when :waiting_for_lparen
          if t[1] == :on_lparen
            state = :waiting_for_first_arg
          end
        when :waiting_for_first_arg
          unless whitespace?(t)
            @column_of_1st_arg = t[0][1]
            state = :waiting_for_newline
          end
        when :waiting_for_newline
          case t[1]
          when :on_ignored_nl, :on_nl
            state = :waiting_for_arg if @paren_stack == ['(']
          end
        when :waiting_for_arg
          unless whitespace?(t)
            if t[0][1] != @column_of_1st_arg
              index = t[0][0] - 1
              add_offence(:convention, index, source[index], ERROR_MESSAGE)
            end
            state = :waiting_for_newline
          end
        end

        @inside_string = true if ([:on_tstring_beg,
                                   :on_regexp_beg].include?(t[1]) ||
                                  t[1..2] == [:on_symbeg, ":\""])
        @inside_string = false if [:on_tstring_end,
                                   :on_regexp_end].include?(t[1])
        unless @inside_string
          case t[2]
          when '(', '{', '[', 'do'
            @paren_stack.push(t[2])
          when ')', '}', ']'
            popped = @paren_stack.pop
            if popped != MATCHING_PAREN[t[2]]
              fail "#{popped} != #{MATCHING_PAREN[t[2]]}"
            end
          when 'end'
            # TODO: This is not foolproof. The 'end' can belong to
            # something other than 'do'.
            @paren_stack.pop if @paren_stack[-1] == 'do'
          end
        end

        state
      end
    end
  end
end
