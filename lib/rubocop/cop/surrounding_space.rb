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
          pos, name, text = tokens[ix]
          offence_detected = case name
                             when :on_lbracket, :on_lparen
                               tokens[ix + 1][1] == :on_sp
                             when :on_rbracket, :on_rparen
                               prev = previous_non_space(tokens, ix)
                               (prev && prev[0][0] == pos[0] &&
                                tokens[ix - 1][1] == :on_sp)
                             when :on_op
                               text == '**' &&
                                 (whitespace?(tokens[ix - 1]) ||
                                  whitespace?(tokens[ix + 1]))
                             end
          if offence_detected
            index = pos[0] - 1
            kind = case name
                   when :on_lparen, :on_rparen
                     'inside parentheses'
                   when :on_lbracket, :on_rbracket
                     'inside square brackets'
                   when :on_op
                     "around operator #{text}"
                   end
            add_offence(:convention, index, source[index],
                        "Space #{kind} detected.")
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
        parent, child = grammar_path.values_at(-2, -1)
        return true if [:unary, :symbol, :defs, :def, :call].include?(parent)
        return true if [:**, :block_var].include?(child)
        return true if parent == :command_call && child == :'::'
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
