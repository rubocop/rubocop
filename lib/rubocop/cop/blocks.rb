# encoding: utf-8

module Rubocop
  module Cop
    class Blocks < Cop
      ERROR_MESSAGE = ['Avoid using {...} for multi-line blocks.',
                       'Prefer {...} over do...end for single-line blocks.']

      def inspect(file, source, tokens, sexp)
        @file = file

        # The reverse_correlations maps grammar path object ids to
        # token indexes, so we can use it to find the corresponding }
        # for each {.
        reverse_correlations = Hash.new([])
        @correlations.each do |ix, path|
          reverse_correlations[path.object_id] += [ix]
        end
        tokens.each_with_index do |t, ix|
          case [t.type, t.text]
          when [:on_lbrace, '{']
            path = @correlations[ix] or next
            if path.last == :brace_block
              rbrace_ix = reverse_correlations[path.object_id] - [ix]
              if rbrace_ix.empty?
                fail "\n#@file:#{t.pos.lineno}:#{t.pos.column}: " +
                  'Matching brace not found'
              end
              if tokens[*rbrace_ix].pos.lineno > t.pos.lineno
                add_offence(:convention, t.pos.lineno, ERROR_MESSAGE[0])
              end
            end
          when [:on_kw, 'do']
            end_token_ix = ix + tokens[ix..-1].index { |t2| t2.text == 'end' }
            if tokens[end_token_ix].pos.lineno == t.pos.lineno
              add_offence(:convention, t.pos.lineno, ERROR_MESSAGE[1])
            end
          end
        end
      end
    end
  end
end
