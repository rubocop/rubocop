# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for potential uses of the location keywords which can be used as
      # shortcut arguments to `#add_offense`.
      #
      # @example
      #
      #   # bad
      #   add_offense(node, location: node.loc.selector)
      #
      #   # good
      #   add_offense(node, location: :selector)
      class OffenseLocationKeyword < Cop
        MSG = 'Use `:%s` as the location argument to `#add_offense`.'.freeze

        def on_send(node)
          node_type_check(node) do |node_arg, kwargs|
            find_offending_argument(node_arg, kwargs) do |location, keyword|
              add_offense(location, message: format(MSG, keyword))
            end
          end
        end

        private

        def_node_matcher :node_type_check, <<-PATTERN
          (send nil? :add_offense $_node $hash)
        PATTERN

        def_node_matcher :offending_location_argument, <<-PATTERN
          (pair (sym :location) $(send (send $_node :loc) $_keyword))
        PATTERN

        def autocorrect(node)
          (*, keyword) = offending_location_argument(node.parent)

          ->(corrector) { corrector.replace(node.source_range, ":#{keyword}") }
        end

        def find_offending_argument(searched_node, kwargs)
          kwargs.pairs.each do |pair|
            offending_location_argument(pair) do |location, node, keyword|
              yield(location, keyword) if searched_node == node
            end
          end
        end
      end
    end
  end
end
