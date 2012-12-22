# encoding: utf-8

require_relative 'grammar'

module Rubocop
  module Cop
    class SurroundingSpace < Cop
      ERROR_MESSAGE = 'Surrounding space missing for '

      def inspect(file, source, tokens, sexp)
        Grammar.new(tokens).correlate(sexp).sort.each { |ix, grammar_path|
          pos, name, text = tokens[ix]
          case name
          when :on_op
            unless surrounded_by_whitespace?(tokens[ix - 1, 3])
              unless ok_without_spaces?(grammar_path)
                index = pos[0] - 1
                add_offence(:convention, index, source[index],
                            ERROR_MESSAGE + "operator '#{text}'.")
              end
            end
          when :on_lbrace
            unless surrounded_by_whitespace?(tokens[ix - 1, 3])
              index = pos[0] - 1
              add_offence(:convention, index, source[index],
                          ERROR_MESSAGE + "'{'.")
            end
          when :on_rbrace
            unless whitespace?(tokens[ix - 1])
              index = pos[0] - 1
              add_offence(:convention, index, source[index],
                          "Space missing to the left of '}'.")
            end
          end
        }
        tokens.each_index { |ix|
          pos, name, _ = tokens[ix]
          offence_detected = case name
                             when :on_lbracket, :on_lparen
                               tokens[ix + 1][1] == :on_sp
                             when :on_rbracket, :on_rparen
                               prev = previous_non_space(tokens, ix)
                               (prev && prev[0][0] == pos[0] &&
                                tokens[ix - 1][1] == :on_sp)
                             end
          if offence_detected
            index = pos[0] - 1
            kind = case name
                   when :on_lparen,   :on_rparen   then 'parentheses'
                   when :on_lbracket, :on_rbracket then 'square brackets'
                   end
            add_offence(:convention, index, source[index],
                        "Space inside #{kind} detected.")
          end
        }
      end

      def previous_non_space(tokens, ix)
        (ix - 1).downto(0) { |i|
          t = tokens[i]
          return t unless whitespace?(t)
        }
        nil
      end

      def ok_without_spaces?(grammar_path)
        grandparent, parent, child = grammar_path.values_at(-3, -2, -1)
        return true if [:unary, :symbol, :defs, :def, :call].include?(parent)
        return true if [:rest_param, :blockarg, :block_var, :args_add_star,
                        :args_add_block, :const_path_ref, :dot2,
                        :dot3].include?(child)
        return true if grandparent == :unary && parent == :vcall
        return true if parent == :command_call && child == :'::'
        return true if child == :**
        false
      end

      def surrounded_by_whitespace?(nearby_tokens)
        left, _, right = nearby_tokens
        whitespace?(left) && whitespace?(right)
      end

      def whitespace?(token)
        token.nil? || [:on_sp, :on_ignored_nl, :on_nl].include?(token[1])
      end
    end
  end
end
