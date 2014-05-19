# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for non-ascii characters in indentifier names.
      class AsciiIdentifiers < Cop
        MSG = 'Use only ascii symbols in identifiers.'
        private_constant :MSG

        def investigate(processed_source)
          processed_source.tokens.each do |t|
            next unless t.type == :tIDENTIFIER && !t.text.ascii_only?
            add_offense(nil, t.pos, MSG)
          end
        end
      end
    end
  end
end
