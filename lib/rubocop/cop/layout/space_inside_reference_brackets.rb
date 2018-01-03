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

        BRACKET_METHODS = %i[[] []=].freeze

        def on_send(node)
          return if node.multiline?
          return unless bracket_method?(node)
          tokens = tokens(node)
          left_token = left_ref_bracket(tokens)
          return unless left_token
          right_token = closing_bracket(tokens, left_token)

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
              SpaceCorrector.remove_space(processed_source, corrector,
                                          left, right)
            else
              SpaceCorrector.add_space(processed_source, corrector, left, right)
            end
          end
        end

        private

        def reference_brackets(node)
          tokens = tokens(node)
          left = left_ref_bracket(tokens)
          [left, closing_bracket(tokens, left)]
        end

        def bracket_method?(node)
          _, method, = *node
          BRACKET_METHODS.include?(method)
        end

        def left_ref_bracket(tokens)
          tokens.reverse.find(&:left_ref_bracket?)
        end

        def closing_bracket(tokens, opening_bracket)
          i = tokens.index(opening_bracket)
          inner_left_brackets_needing_closure = 0

          tokens[i..-1].each do |token|
            inner_left_brackets_needing_closure += 1 if token.left_bracket?
            inner_left_brackets_needing_closure -= 1 if token.right_bracket?
            if inner_left_brackets_needing_closure.zero? && token.right_bracket?
              return token
            end
          end
        end
      end
    end
  end
end
