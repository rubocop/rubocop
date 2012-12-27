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
          prev, nxt = tokens.values_at(ix - 1, ix + 1)
          offence_detected = case name
                             when :on_lbracket, :on_lparen
                               nxt[1] == :on_sp
                             when :on_rbracket, :on_rparen
                               if prev[1] == :on_sp
                                 prev_ns = previous_non_space(tokens, ix)
                                 prev_ns && tokens_on_same_row?(prev_ns,
                                                                tokens[ix]) &&
                                   # Avoid double repoting of [ ] and ( )
                                   prev_ns[1] != :on_lbracket &&
                                   prev_ns[1] != :on_lparen
                               end
                             when :on_op
                               text == '**' &&
                                 (whitespace?(prev) || whitespace?(nxt))
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

      private

      def tokens_on_same_row?(t1, t2)
        t1[0][0] == t2[0][0]
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
