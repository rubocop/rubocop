# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      #   Checks that there are no spaces surrounding a dot method call.
      #   # bad
      #   object .some_method
      #
      #   # bad
      #   object. some_method
      #
      #   # bad
      #   object
      #    .some_method .another_method
      #
      #   # good
      #   object.some_method
      #
      #   # good
      #   object
      #    .some_method
      #
      class SpaceAroundMethodCall < Cop
        include SurroundingSpace

        AFTER_MSG = 'Avoid using space after dot in method call.'
        BEFORE_MSG = 'Avoid using space before dot in method call.'

        def on_send(node)
          tokens = tokens(node)

          left = left_side_of_dot(tokens)
          right = right_side_of_dot(tokens)
          dot = dot_token(tokens)
          return unless dot

          no_space_offenses(node, dot, right, AFTER_MSG)
          return if left.line != dot.line

          no_space_offenses(node, left, dot, BEFORE_MSG)
        end

        private

        def dot_token(tokens)
          tokens.reverse.find(&:dot?)
        end

        def left_side_of_dot(tokens)
          dot_token = dot_token(tokens)
          previous_token(dot_token)
        end

        def right_side_of_dot(tokens)
          dot_token = dot_token(tokens)
          next_token(dot_token)
        end

        def previous_token(current_token)
          index = processed_source.tokens.index(current_token)
          index.nil? || index.zero? ? nil : processed_source.tokens[index - 1]
        end

        def next_token(current_token)
          index = processed_source.tokens.index(current_token)
          index.nil? || index.zero? ? nil : processed_source.tokens[index + 1]
        end
      end
    end
  end
end
