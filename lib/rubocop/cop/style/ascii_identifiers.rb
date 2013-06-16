# encoding: utf-8

# rubocop:disable SymbolName

module Rubocop
  module Cop
    module Style
      class AsciiIdentifiers < Cop
        MSG = 'Use only ascii symbols in identifiers.'

        def inspect(source_buffer, source, tokens, ast, comments)
          tokens.each do |t|
            if t.type == :tIDENTIFIER && t.text =~ /[^\x00-\x7f]/
              add_offence(:convention, t.pos, MSG)
            end
          end
        end
      end
    end
  end
end
