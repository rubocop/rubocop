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

        def_node_matcher :node_type_check, <<-PATTERN
          (send nil :add_offense _offender _
            {(const nil :MSG) (send nil :message) (send nil :message _offender)})
        PATTERN

        def on_send(node)
          node_type_check(node) do
            add_offense(node.last_argument)
          end
        end

        def autocorrect(node)
          parent = node.parent
          arguments = parent.arguments
          range =
            Parser::Source::Range.new(parent.source_range.source_buffer,
                                      arguments[-2].loc.expression.end_pos,
                                      arguments.last.loc.expression.end_pos)

          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
