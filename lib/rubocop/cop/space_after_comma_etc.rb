# encoding: utf-8

module Rubocop
  module Cop
    module SpaceAfterCommaEtc
      ERROR_MESSAGE = 'Space missing after %s.'

      def inspect(file, source, sexp)
        # TODO
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
