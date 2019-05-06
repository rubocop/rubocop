# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of semicolon in if statements.
      #
      # @example
      #
      #   # bad
      #   result = if some_condition; something else another_thing end
      #
      #   # good
      #   result = some_condition ? something : another_thing
      #
      class IfWithSemicolon < Cop
        include OnNormalIfUnless

        MSG = 'Do not use if x; Use the ternary operator instead.'

        def on_normal_if_unless(node)
          beginning = node.loc.begin
          return unless beginning&.is?(';')

          add_offense(node)
        end
      end
    end
  end
end
