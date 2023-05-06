# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for places where `case-when` represents a simple 1:1
      # mapping and can be replaced with a hash lookup.
      #
      # @example MinBranchesCount: 3 (default)
      #   # bad
      #   case country
      #   when 'europe'
      #     'http://eu.example.com'
      #   when 'america'
      #     'http://us.example.com'
      #   when 'australia'
      #     'http://au.example.com'
      #   end
      #
      #   # good
      #   SITES = {
      #     'europe'    => 'http://eu.example.com',
      #     'america'   => 'http://us.example.com',
      #     'australia' => 'http://au.example.com'
      #   }
      #   SITES[country]
      #
      # @example MinBranchesCount: 4
      #   # good
      #   case country
      #   when 'europe'
      #     'http://eu.example.com'
      #   when 'america'
      #     'http://us.example.com'
      #   when 'australia'
      #     'http://au.example.com'
      #   end
      #
      class HashLikeCase < Base
        extend AutoCorrector

        include MinBranchesCount

        MSG = 'Consider replacing `case-when` with a hash lookup.'

        # @!method hash_like_case?(node)
        def_node_matcher :hash_like_case?, <<~PATTERN
          (case
            _
            (when
              ${str_type? sym_type?}
              $[!nil? recursive_basic_literal?])+ nil?)
        PATTERN

        def on_case(node)
          return unless min_branches_count?(node)

          hash_like_case?(node) do |condition_nodes, body_nodes|
            if nodes_of_same_type?(condition_nodes) && nodes_of_same_type?(body_nodes)
              add_offense(node) do |corrector|
                autocorrect(corrector, node, condition_nodes, body_nodes)
              end
            end
          end
        end

        private

        def nodes_of_same_type?(nodes)
          nodes.all? { |node| node.type == nodes.first.type }
        end

        def autocorrect(corrector, node, condition_nodes, body_nodes)
          corrector.replace(node, build_replacement(node, condition_nodes, body_nodes))
        end

        def build_replacement(node, condition_nodes, body_nodes)
          "#{build_hash_literal(condition_nodes, body_nodes)}[#{node.condition.source}]"
        end

        def build_hash_literal(condition_nodes, body_nodes)
          format(
            '{ %<content>s }',
            content: condition_nodes.zip(body_nodes).map do |condition_node, body_node|
              "#{condition_node.source} => #{body_node.source}"
            end.join(', ')
          )
        end
      end
    end
  end
end
