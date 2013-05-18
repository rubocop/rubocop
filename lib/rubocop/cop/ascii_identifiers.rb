# encoding: utf-8

module Rubocop
  module Cop
    class AsciiIdentifiers < Cop
      MSG = 'Use only ascii symbols in identifiers.'

      def inspect(file, source, tokens, ast)
        # TODO implement with Parser
      end
    end
  end
end
