# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for trailing conditionals.
      class TrailingConditional < Cop
        include StatementModifier

        def error_message
          'Avoid conditional modifiers (lines that end with conditionals).'
        end

        def on_if(node)
          return unless modifier_if?(node)

          add_offense(node, :expression, error_message)
        end
      end
    end
  end
end
