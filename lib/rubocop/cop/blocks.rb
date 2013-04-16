# encoding: utf-8

module Rubocop
  module Cop
    module Blocks
      def inspect(file, source, tokens, sexp)
        @file = file

        # The @reverse_correlations maps grammar path object ids to
        # token indexes, so we can use it to find the corresponding }
        # for each {.
        @reverse_correlations = Hash.new([])
        @correlations.each do |ix, path|
          @reverse_correlations[path.object_id] += [ix]
        end

        tokens.each_index { |ix| check(tokens, ix) }
      end
    end

    class MultilineBlocks < Cop
      include Blocks
      ERROR_MESSAGE = 'Avoid using {...} for multi-line blocks.'

      def check(tokens, ix)
        t = tokens[ix]
        if [t.type, t.text] == [:on_lbrace, '{']
          path = @correlations[ix] or return
          if path.last == :brace_block
            rbrace_ix = @reverse_correlations[path.object_id] - [ix]
            if rbrace_ix.empty?
              fail "\n#{@file}:#{t.pos.lineno}:#{t.pos.column}: " +
                'Matching brace not found'
            end
            if tokens[*rbrace_ix].pos.lineno > t.pos.lineno
              add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
            end
          end
        end
      end
    end

    class SingleLineBlocks < Cop
      include Blocks
      ERROR_MESSAGE = 'Prefer {...} over do...end for single-line blocks.'

      def check(tokens, ix)
        t = tokens[ix]
        if [t.type, t.text] == [:on_kw, 'do']
          end_offset = tokens[ix..-1].index { |t2| t2.text == 'end' } or return
          end_token_ix = ix + end_offset
          if tokens[end_token_ix].pos.lineno == t.pos.lineno
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
