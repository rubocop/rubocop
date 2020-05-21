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
      #
      #
      # @example EnforcedStyleForEmptyBrackets: no_space (default)
      #   # The `no_space` EnforcedStyleForEmptyBrackets style enforces that
      #   # empty reference brackets do not contain spaces.
      #
      #   # bad
      #   foo[ ]
      #   foo[     ]
      #
      #   # good
      #   foo[]
      #
      # @example EnforcedStyleForEmptyBrackets: space
      #   # The `space` EnforcedStyleForEmptyBrackets style enforces that
      #   # empty reference brackets contain exactly one space.
      #
      #   # bad
      #   foo[]
      #   foo[    ]
      #
      #   # good
      #   foo[ ]
      #
      class SpaceInsideReferenceBrackets < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = '%<command>s space inside reference brackets.'
        EMPTY_MSG = '%<command>s space inside empty reference brackets.'

        BRACKET_METHODS = %i[[] []=].freeze

        def on_send(node)
          return if node.multiline?
          return unless bracket_method?(node)

          tokens = tokens(node)
          left_token = left_ref_bracket(node, tokens)
          return unless left_token

          right_token = closing_bracket(tokens, left_token)

          if empty_brackets?(left_token, right_token)
            return empty_offenses(node, left_token, right_token, EMPTY_MSG)
          end

          if style == :no_space
            no_space_offenses(node, left_token, right_token, MSG)
          else
            space_offenses(node, left_token, right_token, MSG)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            left, right = reference_brackets(node)

            if empty_brackets?(left, right)
              SpaceCorrector.empty_corrections(processed_source, corrector,
                                               empty_config, left, right)
            elsif style == :no_space
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
          left = left_ref_bracket(node, tokens)
          [left, closing_bracket(tokens, left)]
        end

        def bracket_method?(node)
          BRACKET_METHODS.include?(node.method_name)
        end

        def left_ref_bracket(node, tokens)
          current_token = tokens.reverse.find(&:left_ref_bracket?)
          previous_token = previous_token(current_token)

          if node.method?(:[]=) ||
             previous_token && !previous_token.right_bracket?
            tokens.find(&:left_ref_bracket?)
          else
            current_token
          end
        end

        def closing_bracket(tokens, opening_bracket)
          i = tokens.index(opening_bracket)
          inner_left_brackets_needing_closure = 0

          tokens[i..-1].each do |token|
            inner_left_brackets_needing_closure += 1 if token.left_bracket?
            inner_left_brackets_needing_closure -= 1 if token.right_bracket?
            return token if inner_left_brackets_needing_closure.zero? && token.right_bracket?
          end
        end

        def previous_token(current_token)
          index = processed_source.tokens.index(current_token)
          index.nil? || index.zero? ? nil : processed_source.tokens[index - 1]
        end

        def empty_config
          cop_config['EnforcedStyleForEmptyBrackets']
        end
      end
    end
  end
end
