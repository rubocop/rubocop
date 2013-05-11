# encoding: utf-8

module Rubocop
  module Cop
    class Semicolon < Cop
      ERROR_MESSAGE = 'Do not use semicolons to terminate expressions.'

      def inspect(file, source, tokens, sexp)
        @tokens = tokens
        already_checked_line = nil
        tokens.each_with_index do |t, ix|
          if t.type == :on_semicolon
            next if t.pos.lineno == already_checked_line # fast-forward
            token_1_ix = index_of_first_token_on_line(ix, t.pos.lineno)
            if %w(def class module).include?(tokens[token_1_ix].text)
              handle_exceptions_to_the_rule(token_1_ix)
              if source[t.pos.lineno - 1] =~ /;\s*(#.*)?$/
                # Semicolons at end of a lines are always reported.
                add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
              end
              # When dealing with these one line definitions, we check
              # the whole line at once. That's why we use the variable
              # already_checked_line to know when to fast-forward past
              # the current line.
              already_checked_line = t.pos.lineno
            else
              add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
            end
          end
        end
      end

      def index_of_first_token_on_line(ix, lineno)
        # Index of last token on the previous line
        prev_line_ix =
          @tokens[0...ix].rindex { |t| t.pos.lineno < lineno } || -1
        first = prev_line_ix + 1
        # Index of first non-whitespace token on the current line.
        first + @tokens[first..ix].index { |t| !whitespace?(t) }
      end

      def handle_exceptions_to_the_rule(token_1_ix)
        # We only do further checking of the def case, which means
        # that there are some cases of semicolon usage within
        # non-empty one-line class or method definitions that we don't
        # catch, but these should be rare.
        if @tokens[token_1_ix].text == 'def'
          state = :initial
          @tokens[token_1_ix..-1].each do |t|
            state = next_state(state, t) || state
            break if t.text == 'end'
          end
        end
      end

      def next_state(state, token)
        return nil if whitespace?(token) # no state change for whitespace

        case state
        when :initial
          :def_kw if token.type == :on_kw
        when :def_kw
          :method_name if token.type == :on_ident
        when :method_name
          case token.type
          when :on_lparen then :inside_param_list
          when :on_semicolon then :method_body
          end
        when :inside_param_list
          :right_after_param_list if token.type == :on_rparen
        when :right_after_param_list
          if token.type == :on_semicolon
            unless Semicolon.config['AllowAfterParameterListInOneLineMethods']
              add_offence(:convention, token.pos.lineno, ERROR_MESSAGE)
            end
          end
          :method_body
        when :method_body
          :semicolon_used if token.type == :on_semicolon
        when :semicolon_used
          if token.text != 'end' ||
              !Semicolon.config['AllowBeforeEndInOneLineMethods']
            add_offence(:convention, token.pos.lineno, ERROR_MESSAGE)
          end
          :method_body
        end
      end
    end
  end
end
