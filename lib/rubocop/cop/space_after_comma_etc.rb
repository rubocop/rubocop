# encoding: utf-8

module Rubocop
  module Cop
    module SpaceAfterCommaEtc
      ERROR_MESSAGE = 'Space missing after %s.'

      def inspect(file, source, tokens, sexp)
        tokens.each_cons(2) do |t1, t2|
          if kind(t1) && !whitespace?(t2)
            add_offence(:convention, t1.pos.lineno,
                        sprintf(ERROR_MESSAGE, kind(t1)))
          end
        end
      end
    end

    class SpaceAfterComma < Cop
      include SpaceAfterCommaEtc
      def kind(token)
        'comma' if token.type == :on_comma
      end
    end

    class SpaceAfterSemicolon < Cop
      include SpaceAfterCommaEtc
      def kind(token)
        'semicolon' if token.type == :on_semicolon
      end
    end

    class SpaceAfterColon < Cop
      include SpaceAfterCommaEtc
      def kind(token)
        case token.type
        when :on_label then 'colon'
        when :on_op    then 'colon' if token.text == ':'
        end
      end
    end
  end
end
