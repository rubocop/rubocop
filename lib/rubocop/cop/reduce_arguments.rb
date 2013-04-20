# encoding: utf-8

module Rubocop
  module Cop
    class ReduceArguments < Cop
      ERROR_MESSAGE = 'Name reduce arguments |a, e| (accumulator, element)'

      def inspect(file, source, tokens, sexp)
        find_reduce_blocks(tokens).each do |reduce_block|
          l_ix, r_ix = reduce_block
          unless arguments_named_properly?(l_ix, r_ix, tokens)
            add_offence(:convention, tokens[l_ix].pos.lineno, ERROR_MESSAGE)
          end
        end
      end

      private

      def arguments_named_properly?(l_ix, r_ix, tokens)
        a, e = false, false
        tokens[l_ix..r_ix].each do |t|
          if a == true && [t.type, t.text] == [:on_ident, 'e']
            e = true
          elsif [t.type, t.text] == [:on_ident, 'a']
            a = true
          end
        end
        a && e
      end

      def find_reduce_blocks(tokens)
        blocks = []
        tokens.each_with_index do |t, ix|
          if [t.type, t.text] == [:on_ident, 'reduce']
            # Make sure we didn't select a :reduce symbol
            next if tokens[ix - 1].text == ':'

            block = find_brace_block(tokens, ix)
            blocks << block if block
          end
        end
        blocks
      end

      def find_brace_block(tokens, reduce_ix)
        stack = []
        block = false

        # When we find the braces we need to add reduce_ix in order to
        # find the real tokens index, since we're looping through a subset
        tokens[reduce_ix..-1].each_with_index do |t, ix|
          break if t.pos.lineno != tokens[reduce_ix].pos.lineno
          if [:on_lbrace, :on_tlambeg].include? t.type
            stack.push ix + reduce_ix
          elsif t.type == :on_rbrace
            left_ix = stack.pop
            ix += reduce_ix
            block = [left_ix, ix] if (stack.empty? &&
                                      tokens[left_ix].type != :on_tlambeg)
          end
        end

        block
      end
    end
  end
end
