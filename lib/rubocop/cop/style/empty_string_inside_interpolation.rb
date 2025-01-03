# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for empty strings being assigned inside string interpolation.
      #
      # Empty strings are a meaningless outcome inside of string interpolation, so we remove them.
      #
      # While this cop would also apply to variables that are only going to be used as strings,
      # RuboCop can't detect that, so we only check inside of string interpolation.
      #
      # @example
      #   # bad
      #   "#{condition ? 'foo' : ''}"
      #
      #   # good
      #   "#{'foo' if condition}"
      #
      #   # bad
      #   "#{condition ? '' : 'foo'}"
      #
      #   # good
      #   "#{'foo' unless condition}"
      #
      class EmptyStringInsideInterpolation < Base
        include Interpolation
        extend AutoCorrector
        MSG = 'Do not assign empty strings to variables inside string interpolation.'

        def on_interpolation(node)
          node.each_child_node(:if) do |child_node|
            if empty_if_outcome(child_node)
              autocorrect(child_node, child_node.else_branch.source, 'unless')
            end

            if empty_else_outcome(child_node)
              autocorrect(child_node, child_node.if_branch.source, 'if')
            end
          end
        end

        private

        def empty_if_outcome(node)
          node.if_branch&.nil_type? || node.if_branch&.value&.empty?
        end

        def empty_else_outcome(node)
          node.else_branch&.nil_type? || node.else_branch&.value&.empty?
        end

        def autocorrect(node, outcome, condition)
          add_offense(node) do |corrector|
            corrector.replace(node, "#{outcome} #{condition} #{node.condition.source}")
          end
        end
      end
    end
  end
end
