# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for if and unless statements used as modifiers of other if or
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

        MSG = 'Avoid modifier `%<keyword>s` after another conditional.'.freeze

        def on_if(node)
          return unless node.modifier_form? && node.body.if_type?

          add_offense(node, location: :keyword,
                            message: format(MSG, keyword: node.keyword))
        end
      end
    end
  end
end
