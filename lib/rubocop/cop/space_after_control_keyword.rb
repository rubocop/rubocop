# encoding: utf-8

module Rubocop
  module Cop
    class SpaceAfterControlKeyword < Cop
      ERROR_MESSAGE = 'Use space after control keywords.'

      KEYWORDS = %w(if elsif case when while until unless)

      def inspect(file, source, tokens, sexp)
        # we need to keep track of the previous token to
        # avoid confusing symbols like :if with real keywords
        prev = Token.new(0, :init, '')

        tokens.each_cons(2) do |t1, t2|
          if prev.type != :on_symbeg && t1.type == :on_kw &&
              KEYWORDS.include?(t1.text) && t2.type != :on_sp
            add_offence(:convention,
                        t1.pos.lineno,
                        ERROR_MESSAGE)
          end

          prev = t1
        end
      end
    end
  end
end
