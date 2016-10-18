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
      class LineEndConcatenation < Cop
        MSG = 'Use `\\` instead of `+` or `<<` to concatenate ' \
              'those strings.'.freeze
        CONCAT_TOKEN_TYPES = [:tPLUS, :tLSHFT].freeze
        SIMPLE_STRING_TOKEN_TYPE = :tSTRING
        COMPLEX_STRING_EDGE_TOKEN_TYPES = [:tSTRING_BEG, :tSTRING_END].freeze
        HIGH_PRECEDENCE_OP_TOKEN_TYPES = [:tSTAR2, :tPERCENT, :tDOT,
                                          :tLBRACK2].freeze
        QUOTE_DELIMITERS = %w[' "].freeze

        def investigate(processed_source)
          processed_source.tokens.each_index do |index|
            check_token_set(index)
          end
        end

        def autocorrect(operator_range)
          # Include any trailing whitespace so we don't create a syntax error.
          operator_range = range_with_surrounding_space(operator_range,
                                                        :right,
                                                        false)
          one_more_char = operator_range.resize(operator_range.size + 1)
          # Don't create a double backslash at the end of the line, in case
          # there already was a backslash after the concatenation operator.
          operator_range = one_more_char if one_more_char.source.end_with?('\\')

          ->(corrector) { corrector.replace(operator_range, '\\') }
        end

        private

        def check_token_set(index)
          predecessor, operator, successor = processed_source.tokens[index, 3]

          return unless eligible_successor?(successor) &&
                        eligible_operator?(operator) &&
                        eligible_predecessor?(predecessor)

          return if operator.pos.line == successor.pos.line

          next_successor = token_after_last_string(successor, index)

          return unless eligible_next_successor?(next_successor)

          add_offense(operator.pos, operator.pos)
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
          begin_token, end_token = COMPLEX_STRING_EDGE_TOKEN_TYPES
          if successor.type == begin_token
            ends_to_find = 1
            while ends_to_find > 0
              case processed_source.tokens[index].type
              when begin_token then ends_to_find += 1
              when end_token then ends_to_find -= 1
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
