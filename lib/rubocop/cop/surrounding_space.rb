# encoding: utf-8

require_relative 'grammar'

module Rubocop
  module Cop
    module SurroundingSpace
      def inspect(file, source, tokens, sexp)
        @correlations.sort.each do |ix, grammar_path|
          check_missing(tokens, ix, grammar_path)
        end
        tokens.each_index { |ix| check_extra(tokens, ix) }
      end

      private

      def tokens_on_same_row?(t1, t2)
        t1.pos.lineno == t2.pos.lineno
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

      # Default implementation for classes that don't need it.
      def check_missing(tokens, ix, grammar_path)
      end
    end

    class SpaceAroundOperators < Cop
      include SurroundingSpace
      ERROR_MESSAGE = 'Surrounding space missing for operator '

      def check_missing(tokens, ix, grammar_path)
        t = tokens[ix]
        if t.type == :on_op
          unless surrounded_by_whitespace?(tokens[ix - 1, 3])
            unless ok_without_spaces?(grammar_path)
              add_offence(:convention, t.pos.lineno,
                          ERROR_MESSAGE + "'#{t.text}'.")
            end
          end
        end
      end

      def check_extra(tokens, ix)
        prev, t, nxt = tokens.values_at(ix - 1, ix, ix + 1)
        if t.type == :on_op && t.text == '**' &&
            (whitespace?(prev) || whitespace?(nxt))
          add_offence(:convention, t.pos.lineno,
                      "Space around operator #{t.text} detected.")
        end
      end
    end

    class SpaceAroundBraces < Cop
      include SurroundingSpace

      def check_extra(tokens, ix)
      end

      def check_missing(tokens, ix, grammar_path)
        t = tokens[ix]
        case t.type
        when :on_lbrace
          unless surrounded_by_whitespace?(tokens[ix - 1, 3])
            add_offence(:convention, t.pos.lineno,
                        "Surrounding space missing for '{'.")
          end
        when :on_rbrace
          unless whitespace?(tokens[ix - 1])
            add_offence(:convention, t.pos.lineno,
                        "Space missing to the left of '}'.")
          end
        end
      end
    end

    class SpaceInsideParens < Cop
      include SurroundingSpace
      def check_extra(tokens, ix)
        prev, t, nxt = tokens.values_at(ix - 1, ix, ix + 1)
        offence_detected = case t.type
                           when :on_lparen
                             nxt.type == :on_sp
                           when :on_rparen
                             if prev.type == :on_sp
                               prev_ns = previous_non_space(tokens, ix)
                               prev_ns && tokens_on_same_row?(prev_ns,
                                                              tokens[ix]) &&
                                 # Avoid double repoting of ( )
                                 prev_ns.type != :on_lparen
                             end
                           end
        if offence_detected
          add_offence(:convention, t.pos.lineno,
                      'Space inside parentheses detected.')
        end
      end
    end

    class SpaceInsideBrackets < Cop
      include SurroundingSpace
      def check_extra(tokens, ix)
        prev, t, nxt = tokens.values_at(ix - 1, ix, ix + 1)
        offence_detected = case t.type
                           when :on_lbracket
                             nxt.type == :on_sp
                           when :on_rbracket
                             if prev.type == :on_sp
                               prev_ns = previous_non_space(tokens, ix)
                               prev_ns && tokens_on_same_row?(prev_ns,
                                                              tokens[ix]) &&
                                 # Avoid double repoting of [ ] and ( )
                                 prev_ns.type != :on_lbracket
                             end
                           end
        if offence_detected
          add_offence(:convention, t.pos.lineno,
                      'Space inside square brackets detected.')
        end
      end
    end
  end
end
