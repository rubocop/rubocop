module Rubocop
  module Cop
    class SurroundingSpace < Cop
      ERROR_MESSAGE = 'Surrounding space missing '
      ONLY_BINARY = %w(|| && = == === != += -= *= /= |= ||= &= &&= ** ~= !~ =>)

      def inspect(file, source, tokens, sexp)
        tokens.each_with_index { |tok, ix|
          pos, name, text = tok
          if name == :on_op && ! is_surrounded_by_whitespace(*tokens[ix - 1, 3])
            unless is_ok_without_spaces(tokens, ix, sexp)
              index = pos[0] - 1
              add_offence(:convention, index, source[index],
                          ERROR_MESSAGE + "for operator '" + text + "'.")
            end
          end
        }
      end

      def is_ok_without_spaces(tokens, ix, sexp)
        text = tokens[ix].last
        return false if ONLY_BINARY.include?(text)
        return true if token_is_part_of([:unary, :rest_param, :blockarg,
                                         :args_add_star, :args_add_block],
                                        tokens[ix], sexp)
        return true if %w(.. ::).include?(text)

        prev = first_non_whitespace(tokens, ix, -1, -2)
        return true if prev[1..-1] == [:on_kw, "def"]
        return true if text == '|' && (prev[1] == :on_lbrace ||
                                       prev[2] == 'do' ||
                                       token_is_part_of([:block_var],
                                                        tokens[ix - 2],
                                                        sexp))
        nxt = first_non_whitespace(tokens, ix, 1, 2)
        return true if text == '&' && nxt[1] == :on_symbeg
      end

      def first_non_whitespace(tokens, ix, first_offset, second_offset)
        if is_whitespace(tokens[ix + first_offset])
          tokens[ix + second_offset]
        else
          tokens[ix + first_offset]
        end
      end

      def is_surrounded_by_whitespace(left, _, right)
        is_whitespace(left) && is_whitespace(right)
      end

      def is_whitespace(token)
        token[1] == :on_sp || token[1] == :on_ignored_nl
      end

      # Returns true if token belongs to any of the grammatical
      # entities listed in symbols.
      def token_is_part_of(symbols, token, sexp)
        pos, _, text = token
        chain = get_chain(sexp, pos) or return false
        symbols.find { |symbol| chain.include?(symbol) }
      end

      # Returns the grammar chain from the top down to a token at the
      # given position or nearest place after it, for example,
      # [:program, :def, :paren, :params, :blockarg, :@ident].
      def get_chain(sexp, pos, path = [])
        if (has_position?(sexp) &&
            sexp.last[0] >= pos[0] && sexp.last[1] >= pos[1])
          return path + [sexp.first]
        end
        if [Symbol, Array].include? sexp.first.class
          path = path + [sexp.first] if Symbol === sexp.first
          sexp.each { |sub|
            if Array === sub && (Array === sub.first || Symbol === sub.first)
              res = get_chain(sub, pos, path)
              return res if res
            end
          }
        end
        nil
      end

      # Returns true if the given sexp is on a format containing a
      # position, e.g., [:@ident, "delete", [5, 16]].
      def has_position?(sexp)
        Array === sexp && sexp.size == 3 &&
          Array === sexp.last && sexp.last.size == 2 &&
          Fixnum === sexp.last[0] && Fixnum === sexp.last[1]
      end
    end
  end
end
