# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class TrivialAccessors < Cop
        MSG = 'Use attr_%s to define trivial %s methods.'

        def on_def(node)
          method_name, args, body = *node

          kind = if body && body.type == :ivar
                   'reader'
                 elsif args.children.size == 1 &&
                       body && body.type == :ivasgn &&
                       body.children[1] && body.children[1].type == :lvar &&
                       method_name != :initialize
                   'writer'
                 end
          if kind
            add_offence(:convention, node.loc.keyword,
                        sprintf(MSG, kind, kind))
          end

          super
        end
      end
    end
  end
end
