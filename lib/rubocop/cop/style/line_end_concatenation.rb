# frozen_string_literal: true

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
      class LineEndConcatenation < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `\\` instead of `+` or `<<` to concatenate ' \
              'those strings.'
        CONCAT_TOKEN_TYPES = %i[tPLUS tLSHFT].freeze
        SIMPLE_STRING_TOKEN_TYPE = :tSTRING
        COMPLEX_STRING_BEGIN_TOKEN = :tSTRING_BEG
        COMPLEX_STRING_END_TOKEN = :tSTRING_END
        HIGH_PRECEDENCE_OP_TOKEN_TYPES = %i[tSTAR2 tPERCENT tDOT
                                            tLBRACK2].freeze
        QUOTE_DELIMITERS = %w[' "].freeze

        def self.autocorrect_incompatible_with
          [Style::RedundantInterpolation]
        end

        def on_new_investigation
          processed_source.tokens.each_index do |index|
            check_token_set(index)
          end
        end

        private

        def check_token_set(index)
          predecessor, operator, successor = processed_source.tokens[index, 3]

          return unless eligible_token_set?(predecessor, operator, successor)

          return if operator.line == successor.line

          next_successor = token_after_last_string(successor, index)

          return unless eligible_next_successor?(next_successor)

          add_offense(operator.pos) do |corrector|
            autocorrect(corrector, operator.pos)
          end
        end

        def autocorrect(corrector, operator_range)
          # Include any trailing whitespace so we don't create a syntax error.
          operator_range = range_with_surrounding_space(range: operator_range,
                                                        side: :right,
                                                        newlines: false)
          one_more_char = operator_range.resize(operator_range.size + 1)
          # Don't create a double backslash at the end of the line, in case
          # there already was a backslash after the concatenation operator.
          operator_range = one_more_char if one_more_char.source.end_with?('\\')

          corrector.replace(operator_range, '\\')
        end

        def eligible_token_set?(predecessor, operator, successor)
          eligible_successor?(successor) &&
            eligible_operator?(operator) &&
            eligible_predecessor?(predecessor)
        end

        def eligible_successor?(successor)
          successor && standard_string_literal?(successor)
        end

        def eligible_operator?(operator)
          CONCAT_TOKEN_TYPES.include?(operator.type)
        end

        def eligible_next_successor?(next_successor)
          !(next_successor &&
            HIGH_PRECEDENCE_OP_TOKEN_TYPES.include?(next_successor.type))
        end

        def eligible_predecessor?(predecessor)
          standard_string_literal?(predecessor)
        end

        def token_after_last_string(successor, base_index)
          index = base_index + 3
          if successor.type == COMPLEX_STRING_BEGIN_TOKEN
            ends_to_find = 1
            while ends_to_find.positive?
              case processed_source.tokens[index].type
              when COMPLEX_STRING_BEGIN_TOKEN then ends_to_find += 1
              when COMPLEX_STRING_END_TOKEN then ends_to_find -= 1
              end
              index += 1
            end
          end
          processed_source.tokens[index]
        end

        def standard_string_literal?(token)
          case token.type
          when SIMPLE_STRING_TOKEN_TYPE
            true
          when COMPLEX_STRING_BEGIN_TOKEN, COMPLEX_STRING_END_TOKEN
            QUOTE_DELIMITERS.include?(token.text)
          else
            false
          end
        end
      end
    end
  end
end
