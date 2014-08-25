# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for string literal concatenation at
      # the end of a line.
      #
      # @example
      #
      #   # bad
      #   some_str = 'ala' +
      #              'bala'
      #
      #   some_str = 'ala' <<
      #              'bala'
      #
      #   # good
      #   some_str = 'ala' \
      #              'bala'
      #
      class LineEndConcatenation < Cop
        MSG = 'Use `\\` instead of `+` or `<<` to concatenate those strings.'
        CONCAT_TOKEN_TYPES = [:tPLUS, :tLSHFT].freeze
        SIMPLE_STRING_TOKEN_TYPE = :tSTRING
        COMPLEX_STRING_EDGE_TOKEN_TYPES = [:tSTRING_BEG, :tSTRING_END].freeze
        QUOTE_DELIMITERS = %w(' ").freeze

        def investigate(processed_source)
          processed_source.tokens.each_cons(3) do |tokens|
            check_token_set(*tokens)
          end
        end

        def autocorrect(operator_range)
          @corrections << lambda do |corrector|
            corrector.replace(operator_range, '\\')
          end
        end

        private

        def check_token_set(predecessor, operator, successor)
          return unless CONCAT_TOKEN_TYPES.include?(operator.type)
          return unless standard_string_literal?(predecessor)
          return unless standard_string_literal?(successor)
          return if operator.pos.line == successor.pos.line
          add_offense(operator.pos, operator.pos)
        end

        def standard_string_literal?(token)
          case token.type
          when SIMPLE_STRING_TOKEN_TYPE
            true
          when *COMPLEX_STRING_EDGE_TOKEN_TYPES
            QUOTE_DELIMITERS.include?(token.text)
          else
            false
          end
        end
      end
    end
  end
end
