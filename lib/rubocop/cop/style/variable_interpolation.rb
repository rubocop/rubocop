# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for variable interpolation (like "#@ivar").
      #
      # @example
      #   # bad
      #   "His name is #$name"
      #   /check #$pattern/
      #   "Let's go to the #@store"
      #
      #   # good
      #   "His name is #{$name}"
      #   /check #{$pattern}/
      #   "Let's go to the #{@store}"
      class VariableInterpolation < Cop
        include Interpolation

        MSG = 'Replace interpolated variable `%<variable>s` ' \
              'with expression `#{%<variable>s}`.'

        def on_node_with_interpolations(node)
          node.children.each do |child|
            next unless child.variable? || child.reference?

            add_offense(child)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node, "{#{node.source}}")
          end
        end

        private

        def message(node)
          format(MSG, variable: node.source)
        end
      end
    end
  end
end
