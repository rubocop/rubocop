# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks that environments called with `Rails.env` predicates
      # exist.
      #
      # @example
      #   # bad
      #   Rails.env.proudction?
      #
      #   # good
      #   Rails.env.production?
      class UnknownEnv < Cop
        include NameSimilarity

        MSG = 'Unknown environment `%<name>s`.'
        MSG_SIMILAR = 'Unknown environment `%<name>s`. ' \
                      'Did you mean `%<similar>s`?'

        def_node_matcher :unknown_environment?, <<-PATTERN
          (send
            (send
              {(const nil? :Rails) (const (cbase) :Rails)}
              :env)
            $#unknown_env_name?)
        PATTERN

        def on_send(node)
          unknown_environment?(node) do |name|
            add_offense(node, location: :selector, message: message(name))
          end
        end

        private

        def collect_variable_like_names(_scope)
          environments.map { |env| env + '?' }
        end

        def message(name)
          similar = find_similar_name(name.to_s, [])
          if similar
            format(MSG_SIMILAR, name: name, similar: similar)
          else
            format(MSG, name: name)
          end
        end

        def unknown_env_name?(name)
          name = name.to_s
          name.end_with?('?') &&
            !environments.include?(name[0..-2])
        end

        def environments
          cop_config['Environments']
        end
      end
    end
  end
end
