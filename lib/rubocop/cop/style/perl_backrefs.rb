# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of Perl-style regexp match
      # backreferences like $1, $2, etc.
      class PerlBackrefs < Cop
        MSG = 'Avoid the use of Perl-style backrefs.'

        def on_nth_ref(node)
          add_offence(node, :expression)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            backref, = *node

            corrector.replace(node.loc.expression,
                              "Regexp.last_match[#{backref}]")
          end
        end
      end
    end
  end
end
