# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of Perl-style regexp match
      # backreferences like $1, $2, etc.
      class PerlBackrefs < Cop
        MSG = 'Avoid the use of Perl-style backrefs.'.freeze

        def on_nth_ref(node)
          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            backref, = *node
            parent_type = node.parent ? node.parent.type : nil
            if [:dstr, :xstr, :regexp].include?(parent_type)
              corrector.replace(node.source_range,
                                "{Regexp.last_match(#{backref})}")
            else
              corrector.replace(node.source_range,
                                "Regexp.last_match(#{backref})")
            end
          end
        end
      end
    end
  end
end
