# encoding: utf-8

require_relative 'grammar'

module Rubocop
  module Cop
    class SurroundingSpace < Cop
      ERROR_MESSAGE = 'Surrounding space missing for '

      def inspect(file, source, tokens, sexp)
        Grammar.new(tokens).correlate(sexp).sort.each do |ix, grammar_path|
          t = tokens[ix]
          case t.name
          when :on_op
            unless surrounded_by_whitespace?(tokens[ix - 1, 3])
              unless ok_without_spaces?(grammar_path)
                index = t.pos.row - 1
                add_offence(:convention, index, source[index],
                            ERROR_MESSAGE + "operator '#{t.text}'.")
              end
            end
          when :on_lbrace
            unless surrounded_by_whitespace?(tokens[ix - 1, 3])
              index = t.pos.row - 1
              add_offence(:convention, index, source[index],
                          ERROR_MESSAGE + "'{'.")
            end
          when :on_rbrace
            unless whitespace?(tokens[ix - 1])
              index = t.pos.row - 1
              add_offence(:convention, index, source[index],
                          "Space missing to the left of '}'.")
            end
          end
        end
        tokens.each_index do |ix|
          t = tokens[ix]
          prev, nxt = tokens.values_at(ix - 1, ix + 1)
          offence_detected = case t.name
                             when :on_lbracket, :on_lparen
                               nxt.name == :on_sp
                             when :on_rbracket, :on_rparen
                               if prev.name == :on_sp
                                 prev_ns = previous_non_space(tokens, ix)
                                 prev_ns && tokens_on_same_row?(prev_ns,
                                                                tokens[ix]) &&
                                   # Avoid double repoting of [ ] and ( )
                                   prev_ns.name != :on_lbracket &&
                                   prev_ns.name != :on_lparen
                               end
                             when :on_op
                               t.text == '**' &&
                                 (whitespace?(prev) || whitespace?(nxt))
                             end
          if offence_detected
            index = t.pos.row - 1
            kind = case t.name
                   when :on_lparen, :on_rparen
                     'inside parentheses'
                   when :on_lbracket, :on_rbracket
                     'inside square brackets'
                   when :on_op
                     "around operator #{t.text}"
                   end
            add_offence(:convention, index, source[index],
                        "Space #{kind} detected.")
          end
        end
      end

      private

      def tokens_on_same_row?(t1, t2)
        t1.pos.row == t2.pos.row
      end

      def previous_non_space(tokens, ix)
        (ix - 1).downto(0) do |i|
          t = tokens[i]
          return t unless whitespace?(t)
        end
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
    end
  end
end
