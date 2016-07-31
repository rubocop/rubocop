# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for if and unless statements used as modifers of other if or
      # unless statements.
      #
      # @example
      #
      #  # bad
      #  tired? ? 'stop' : 'go faster' if running?
      #
      #  # bad
      #  if tired?
      #    "please stop"
      #  else
      #    "keep going"
      #  end if running?
      #
      #  # good
      #  if running?
      #    tired? ? 'stop' : 'go faster'
      #  end
      class IfUnlessModifierOfIfUnless < Cop
        include StatementModifier

        MESSAGE = 'Avoid modifier `%s` after another conditional.'.freeze

        def message(keyword)
          format(MESSAGE, keyword)
        end

        def on_if(node)
          return unless modifier_if?(node)
          _cond, body, _else = if_node_parts(node)
          return unless body.if_type?

          add_offense(node, :keyword, message(node.loc.keyword.source))
        end
      end
    end
  end
end
