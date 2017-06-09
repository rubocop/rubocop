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
      #   add_offense(node, node.loc.selector)
      #
      #   # good
      #   add_offense(node, :selector)
      class OffenseLocationKeyword < Cop
        MSG = 'Use `:%s` as the location argument to `#add_offense`.'.freeze

        def on_send(node)
          offense_location(node) do |location_argument, keyword|
            add_offense(node, location_argument.loc.expression,
                        format(MSG, keyword))
          end
        end

        private

        def_node_matcher :offense_location, <<-PATTERN
          (send nil :add_offense _offender
            $(send (send _offender :loc) $_) ...)
        PATTERN

        def autocorrect(node)
          lambda do |corrector|
            offense_location(node) do |location_argument, keyword|
              corrector.replace(location_argument.loc.expression, ":#{keyword}")
            end
          end
        end
      end
    end
  end
end
