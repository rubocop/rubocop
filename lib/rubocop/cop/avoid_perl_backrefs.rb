# encoding: utf-8

module Rubocop
  module Cop
    class AvoidPerlBackrefs < Cop
      def inspect(file, source, tokens, ast)
        on_node(:nth_ref, ast) do |node|
          backref = node.src.expression.to_source

          add_offence(
            :convention,
            node.src.line,
            "Prefer the use of MatchData over #{backref}."
          )
        end
      end
    end
  end
end
