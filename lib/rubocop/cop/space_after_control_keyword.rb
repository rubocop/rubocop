# encoding: utf-8

module Rubocop
  module Cop
    class SpaceAfterControlKeyword < Cop
      MSG = 'Use space after control keywords.'

      KEYWORDS = %w(if elsif case when while until unless)

      def inspect(file, source, tokens, ast)
        # TODO
      end
    end
  end
end
