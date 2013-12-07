# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for trivial reader/writer methods, that could
      # have been created with the attr_* family of functions automatically.
      class TrivialAccessors < Cop
        include CheckMethods

        MSG = 'Use attr_%s to define trivial %s methods.'

        private

        def check(node, method_name, args, body)
          kind = if trivial_reader?(method_name, args, body)
                   'reader'
                 elsif trivial_writer?(method_name, args, body)
                   'writer'
                 end
          if kind
            add_offence(node, :keyword,
                        sprintf(MSG, kind, kind))
          end
        end

        def exact_name_match?
          cop_config['ExactNameMatch']
        end

        def allow_predicates?
          cop_config['AllowPredicates']
        end

        def whitelist
          whitelist = cop_config['Whitelist']
          Array(whitelist).map(&:to_sym) + [:initialize]
        end

        def predicate?(method_name)
          method_name[-1] == '?'
        end

        def trivial_reader?(method_name, args, body)
          looks_like_trivial_reader?(args, body) &&
            !allowed_method?(method_name, body)
        end

        def looks_like_trivial_reader?(args, body)
          args.children.size == 0 && body && body.type == :ivar
        end

        def trivial_writer?(method_name, args, body)
          looks_like_trivial_writer?(args, body) &&
            !allowed_method?(method_name, body)
        end

        def looks_like_trivial_writer?(args, body)
          args.children.size == 1 && args.children[0].type != :restarg &&
            body && body.type == :ivasgn &&
            body.children[1] && body.children[1].type == :lvar
        end

        def allowed_method?(method_name, body)
          allow_predicates? && predicate?(method_name) ||
            whitelist.include?(method_name) ||
            exact_name_match? && !names_match?(method_name, body)
        end

        def names_match?(method_name, body)
          ivar_name, = *body

          method_name.to_s.chomp('=') == ivar_name[1..-1]
        end
      end
    end
  end
end
