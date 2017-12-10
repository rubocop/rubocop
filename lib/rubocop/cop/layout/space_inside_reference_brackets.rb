# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that reference brackets have or don't have
      # surrounding space depending on configuration.
      #
      # @example EnforcedStyle: no_space (default)
      #   # The `no_space` style enforces that reference brackets have
      #   # no surrounding space.
      #
      #   # bad
      #   hash[ :key ]
      #   array[ index ]
      #
      #   # good
      #   hash[:key]
      #   array[index]
      #
      # @example EnforcedStyle: space
      #   # The `space` style enforces that reference brackets have
      #   # surrounding space.
      #
      #   # bad
      #   hash[:key]
      #   array[index]
      #
      #   # good
      #   hash[ :key ]
      #   array[ index ]
      class SpaceInsideReferenceBrackets < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = '%<command>s space inside reference brackets.'.freeze

        def on_send(node)
          return if node.multiline?
          return unless left_ref_bracket(node)
          left_token = left_ref_bracket(node)
          right_token = right_ref_bracket(node, left_token)

          if style == :no_space
            no_space_offenses(node, left_token, right_token, MSG)
          else
            space_offenses(node, left_token, right_token, MSG)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            left, right = reference_brackets(node)

            if style == :no_space
              no_space_corrector(corrector, left, right)
            else
              space_corrector(corrector, left, right)
            end
          end
        end

        private

        def reference_brackets(node)
          left = left_ref_bracket(node)
          [left, right_ref_bracket(node, left)]
        end

        def left_ref_bracket(node)
          tokens(node).reverse.find(&:left_ref_bracket?)
        end

        def right_ref_bracket(node, token)
          i = tokens(node).index(token)
          tokens(node).slice(i..-1).find(&:right_bracket?)
        end
      end
    end
  end
end
