# encoding: utf-8

module Rubocop
  module Cop
    class AvoidPerlBackrefs < Cop
      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:nth_ref, sexp) do |s|
          backref = s.src.expression.to_source
          lineno = s.src.expression.line

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
