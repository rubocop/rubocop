# encoding: utf-8

module Rubocop
  module Cop
    class AvoidPerlBackrefs < Cop
      def inspect(file, source, tokens, sexp)
        each(:@backref, sexp) do |s|
          backref = s[1]
          lineno = s[2].lineno

          add_offence(
            :convention,
            lineno,
            "Prefer the use of MatchData over #{backref}."
          )
        end
      end
    end
  end
end
