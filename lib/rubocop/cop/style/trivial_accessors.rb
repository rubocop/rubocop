# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for trivial reader/writer methods, that could
      # have been created with the attr_* family of functions automatically.
      class TrivialAccessors < Cop
        MSG = 'Use attr_%s to define trivial %s methods.'

        def on_def(node)
          method_name, args, body = *node

          kind = if body && body.type == :ivar && predicate?(method_name)
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

        private

        def predicate?(method_name)
          !(method_name[-1] == '?' || TrivialAccessors.allow_predicates)
        end

        def self.allow_predicates
          TrivialAccessors.config['AllowPredicates']
        end
      end
    end
  end
end
