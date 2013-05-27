# encoding: utf-8

# rubocop:disable SymbolName

module Rubocop
  module Cop
    module SpaceAfterCommaEtc
      MSG = 'Space missing after %s.'

      def inspect(source, tokens, ast, comments)
        tokens.each_cons(2) do |t1, t2|
          if kind(t1) && t1.pos.line == t2.pos.line &&
              t2.pos.column == t1.pos.column + offset(t1)
            add_offence(:convention, t1.pos.line, sprintf(MSG, kind(t1)))
          end
        end
      end

      # The normal offset, i.e., the distance from the punctuation
      # token where a space should be, is 1.
      def offset(token)
        1
      end
    end

    class SpaceAfterComma < Cop
      include SpaceAfterCommaEtc

      def kind(token)
        'comma' if token.type == :tCOMMA
      end
    end

    class SpaceAfterSemicolon < Cop
      include SpaceAfterCommaEtc

      def kind(token)
        'semicolon' if token.type == :tSEMI
      end
    end

    class SpaceAfterColon < Cop
      include SpaceAfterCommaEtc

      # The colon following a label will not appear in the token
      # array. Instad we get a tLABEL token, whose length we use to
      # calculate where we expect a space.
      def offset(token)
        case token.type
        when :tLABEL then token.text.length + 1
        when :tCOLON then 1
        end
      end

      def kind(token)
        case token.type
        when :tLABEL, :tCOLON then 'colon'
        end
      end
    end
  end
end
