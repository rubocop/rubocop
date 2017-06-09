# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for redundant message arguments to `#add_offense`. This method
      # will automatically use `#message` or `MSG` (in that order of priority)
      # if they are defined.
      #
      # @example
      #
      #   # bad
      #   add_offense(node, :expression, MSG)
      #   add_offense(node, :expression, message)
      #   add_offense(node, :expression, message(node))
      #
      #   # good
      #   add_offense(node, :expression)
      #   add_offense(node, :expression, CUSTOM_MSG)
      #   add_offense(node, :expression, message(other_node))
      #
      class RedundantMessageArgument < Cop
        MSG = 'Redundant message argument to `#add_offense`.'.freeze

        def_node_search :node_type_check, <<-PATTERN
          (send nil :add_offense _offender _
            {(const nil :MSG) (send nil :message) (send nil :message _offender)})
        PATTERN

        def on_send(node)
          node_type_check(node) do |offense_node|
            add_offense(offense_node.last_argument)
          end
        end
      end
    end
  end
end
