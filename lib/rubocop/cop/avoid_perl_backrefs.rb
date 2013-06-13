# encoding: utf-8

module Rubocop
  module Cop
    class AvoidPerlBackrefs < Cop
      def on_nth_ref(node)
        backref, = *node

        add_offence(:convention,
                    node.loc.expression,
                    "Prefer the use of MatchData over $#{backref}.")

        super
      end
    end
  end
end
