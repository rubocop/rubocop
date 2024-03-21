# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for unescaped closing square bracket metacharacter in Regexp character classes.
      #
      # @example
      #
      #   # bad
      #   r = /abc]123/
      #
      #   # good
      #   r = /abc\]123/
      #
      class UnescapedClosingSquareBracketRegex < Base
        include RangeHelp
        extend AutoCorrector

        MSG_UNESCAPED_BRACKET = 'Regular expression has \']\' without escape'

        METACHARACTER = ']'

        def on_regexp(node)
          each_unescaped_closing_square_bracket_range(node) do |range|
            add_offense(node, message: MSG_UNESCAPED_BRACKET) do |corrector|
              corrector.insert_before(range, '\\')
            end
          end
        end

        private

        def each_unescaped_closing_square_bracket_range(node)
          node.parsed_tree&.each_expression do |expr|
            next if skip_expression?(expr)

            node_start = node.source_range.begin_pos
            find_occurences(expr.text).each do |index|
              pos = expr.ts + index
              yield range_between(node_start + pos, node_start + pos + 1)
            end
          end
        end

        def skip_expression?(expr)
          expr.type != :literal || expr.token != :literal || !expr.text.include?(METACHARACTER)
        end

        def find_occurences(text)
          occurences = []
          return occurences unless (index = text.index(METACHARACTER))

          until index.nil?
            occurences << (index + 1)
            index = text.index(METACHARACTER, index + 1)
          end
          occurences
        end
      end
    end
  end
end
