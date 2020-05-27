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
          return unless node.else_branch

          beginning = node.loc.begin
          return unless beginning&.is?(';')

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node, correct_to_ternary(node))
          end
        end

        private

        def correct_to_ternary(node)
          else_code = node.else_branch ? node.else_branch.source : 'nil'

          "#{node.condition.source} ? #{node.if_branch.source} : #{else_code}"
        end
      end
    end
  end
end
