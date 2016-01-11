# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking for spaces inside various
    # kinds of brackets.
    module SpaceInside
      include SurroundingSpace
      MSG = 'Space inside %s detected.'.freeze

      def investigate(processed_source)
        @processed_source = processed_source
        brackets = Brackets.new(*specifics)
        processed_source.tokens.each_cons(2) do |t1, t2|
          next unless brackets.left_side?(t1) || brackets.right_side?(t2)

          # If the second token is a comment, that means that a line break
          # follows, and that the rules for space inside don't apply.
          next if t2.type == :tCOMMENT
          next unless t2.pos.line == t1.pos.line && space_between?(t1, t2)

          range = Parser::Source::Range.new(processed_source.buffer,
                                            t1.pos.end_pos,
                                            t2.pos.begin_pos)
          add_offense(range, range, format(MSG, brackets.kind))
        end
      end

      def autocorrect(range)
        ->(corrector) { corrector.remove(range) }
      end

      # Wraps info about the brackets. Makes it easy to check whether a token
      # is one of the brackets.
      #
      # @example Parentheses `()`
      #   Brackets.new(:tLPAREN, :tRPAREN, 'parentheses')
      #
      # @example Square brackets `[]`
      #   Brackets.new([:tLBRACK, :tLBRACK2], :tRBRACK, 'square brackets')
      #
      class Brackets
        attr_reader :kind

        def initialize(left, right, kind)
          @left_side_types = [left].flatten
          @right_side_type = right
          @kind = kind
        end

        def left_side?(token)
          # Left side bracket has to be able to match multiple types
          # (e.g. :tLBRACK and :tLBRACK2)
          @left_side_types.include?(token.type)
        end

        def right_side?(token)
          @right_side_type == token.type
        end
      end
    end
  end
end
