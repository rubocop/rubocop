# encoding: utf-8

# rubocop:disable SymbolName

module Rubocop
  module Cop
    module Style
      # This cop checks for non-ascii characters in indentifier names.
      class AsciiIdentifiers < Cop
        MSG = 'Use only ascii symbols in identifiers.'

        def investigate(processed_source)
          processed_source.tokens.each do |t|
            if t.type == :tIDENTIFIER && t.text =~ /[^\x00-\x7f]/
              add_offence(:convention, t.pos, MSG)
            end
          end
        end
      end
    end
  end
end
