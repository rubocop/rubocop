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

          check(node, method_name, args, body)

          super
        end

        def on_defs(node)
          _scope, method_name, args, body = *node

          check(node, method_name, args, body)

          super
        end

        private

        def check(node, method_name, args, body)
          kind = if trivial_reader?(method_name, args, body)
                   'reader'
                 elsif trivial_writer?(method_name, args, body)
                   'writer'
                 end
          if kind
            add_offence(:convention, node.loc.keyword,
                        sprintf(MSG, kind, kind))
          end

        end

        def exact_name_match?
          TrivialAccessors.config['ExactNameMatch']
        end

        def trivial_reader?(method_name, args, body)
          return false unless args.children.size == 0

          return false unless body && body.type == :ivar

          exact_name_match? ? names_match?(method_name, body) : true
        end

        def trivial_writer?(method_name, args, body)
          return false unless args.children.size == 1 &&
            body && body.type == :ivasgn &&
            body.children[1] && body.children[1].type == :lvar &&
            method_name != :initialize

          exact_name_match? ? names_match?(method_name, body) : true
        end

        def names_match?(method_name, body)
          ivar_name, = *body

          method_name.to_s.chomp('=') == ivar_name[1..-1]
        end
      end
    end
  end
end
