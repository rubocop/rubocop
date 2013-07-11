# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of Perl-style regexp match
      # backreferences like $1, $2, etc.
      class AvoidPerlBackrefs < Cop
        def on_nth_ref(node)
          backref, = *node

          add_offence(:convention,
                      node.loc.expression,
                      "Prefer the use of MatchData over $#{backref}.")
        end
      end
    end
  end
end
