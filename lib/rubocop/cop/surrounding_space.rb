# encoding: utf-8

require_relative 'grammar'

module Rubocop
  module Cop
    class SurroundingSpace < Cop
      ERROR_MESSAGE = 'Surrounding space missing for operator'

      def inspect(file, source, tokens, sexp)
        Grammar.new(tokens).correlate(sexp).sort.each { |ix, grammar_path|
          pos, name, text = tokens[ix]
          if name == :on_op
            unless surrounded_by_whitespace?(tokens[ix - 1, 3])
              unless ok_without_spaces?(grammar_path)
                index = pos[0] - 1
                add_offence(:convention, index, source[index],
                            ERROR_MESSAGE + " '#{text}'.")
              end
            end
          end
        }
      end

      def ok_without_spaces?(grammar_path)
        grandparent, parent, child = grammar_path.values_at(-3, -2, -1)
        return true if [:unary, :symbol, :defs, :def, :call].include?(parent)
        return true if [:rest_param, :blockarg, :block_var, :args_add_star,
                        :args_add_block, :const_path_ref, :dot2,
                        :dot3].include?(child)
        return true if grandparent == :unary && parent == :vcall
        return true if parent == :command_call && child == :'::'
        false
      end

      def surrounded_by_whitespace?(nearby_tokens)
        left, _, right = nearby_tokens
        whitespace?(left) && whitespace?(right)
      end

      def whitespace?(token)
        [:on_sp, :on_ignored_nl, :on_nl].include?(token[1])
      end
    end
  end
end
