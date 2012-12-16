require_relative 'grammar'
require 'awesome_print'

module Rubocop
  module Cop
    class SurroundingSpace < Cop
      ERROR_MESSAGE = 'Surrounding space missing '

      def inspect(file, source, tokens, sexp)
        @table = Grammar.new(tokens).correlate(sexp)
        tokens.each_with_index { |tok, ix|
          pos, name, text = tok
          if name == :on_op
            unless is_surrounded_by_whitespace(tokens[ix - 1, 3])
              unless is_ok_without_spaces(tokens, ix, sexp)
                index = pos[0] - 1
                add_offence(:convention, index, source[index],
                            ERROR_MESSAGE + "for operator '" + text + "'.")
              end
            end
          end
        }
      end

      def is_ok_without_spaces(tokens, ix, sexp)
        if @table[ix]
          grandparent, parent, child = @table[ix][-3..-1]
          return true if [:unary, :symbol, :defs].include?(parent)
          return true if [:rest_param, :blockarg, :block_var, :args_add_star,
                          :args_add_block, :const_path_ref].include?(child)
          return true if grandparent == :unary && parent == :vcall
        end
        text = tokens[ix].last
        return true if %w(.. ... ::).include?(text)

        prev = first_non_whitespace(tokens, ix, -1, -2)
        return true if prev[1..-1] == [:on_kw, "def"]
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

      def is_surrounded_by_whitespace(nearby_tokens)
        left, _, right = nearby_tokens
        is_whitespace(left) && is_whitespace(right)
      end

      def is_whitespace(token)
        [:on_sp, :on_ignored_nl, :on_nl].include?(token[1])
      end
    end
  end
end
