# frozen_string_literal: true

module RuboCop
  module Cop
    # This autocorrects parentheses
    class ParenthesesCorrector
      class << self
        include RangeHelp

        COMMA_REGEXP = /(?<=\))\s*,/.freeze

        def correct(corrector, node)
          buffer = node.source_range.source_buffer
          corrector.remove(range_with_surrounding_space(range: node.loc.begin, buffer: buffer,
                                                        side: :right, whitespace: true))
          remove_close_paren(corrector, node, buffer)
          handle_orphaned_comma(corrector, node)

          return unless ternary_condition?(node) && next_char_is_question_mark?(node)

          corrector.insert_after(node.loc.end, ' ')
        end

        private

        # When the line above `)` ends with a comment and a chained call follows `)`,
        # crossing the newline would pull the chain into the comment. Preserve the newline.
        def remove_close_paren(corrector, node, buffer)
          newlines = !comment_above_close_paren_swallows_chain?(node, buffer)
          corrector.remove(range_with_surrounding_space(range: node.loc.end, buffer: buffer,
                                                        side: :left, newlines: newlines))
        end

        def comment_above_close_paren_swallows_chain?(node, buffer)
          last_child = node.children.last
          return false unless last_child

          body_end = last_child.source_range.end_pos
          close_paren_begin = node.loc.end.begin_pos
          return false if body_end >= close_paren_begin

          source_between = buffer.source[body_end...close_paren_begin]
          return false unless source_between.match?(/#[^\n]*\n/)

          chained_after_close_paren?(node)
        end

        def chained_after_close_paren?(node)
          close_paren = node.loc.end
          line_text = close_paren.source_line
          after_paren = line_text[(close_paren.column + 1)..]
          return false if after_paren.nil?

          trimmed = after_paren.lstrip
          !trimmed.empty? && !trimmed.start_with?('#')
        end

        def ternary_condition?(node)
          node.parent&.if_type? && node.parent.ternary?
        end

        def next_char_is_question_mark?(node)
          node.loc.last_column == node.parent.loc.question.column
        end

        def only_closing_paren_before_comma?(node)
          source_buffer = node.source_range.source_buffer
          line_range = source_buffer.line_range(node.loc.end.line)

          line_range.source.start_with?(/\s*\)\s*,/)
        end

        # If removing parentheses leaves a comma on its own line, remove all the whitespace
        # preceding it to prevent a syntax error.
        def handle_orphaned_comma(corrector, node)
          return unless only_closing_paren_before_comma?(node)

          range = extend_range_for_heredoc(node, parens_range(node))
          corrector.remove(range)

          add_heredoc_comma(corrector, node)
        end

        # Get a range for the closing parenthesis and all whitespace to the left of it
        def parens_range(node)
          range_with_surrounding_space(
            range: node.loc.end,
            buffer: node.source_range.source_buffer,
            side: :left,
            newlines: true,
            whitespace: true,
            continuations: true
          )
        end

        # If the node contains a heredoc, remove the comma too
        # It'll be added back in the right place later
        def extend_range_for_heredoc(node, range)
          return range unless heredoc?(node)

          comma_line = range_by_whole_lines(node.loc.end, buffer: node.source_range.source_buffer)
          offset = comma_line.source.match(COMMA_REGEXP)[0]&.size || 0

          range.adjust(end_pos: offset)
        end

        # Add a comma back after the heredoc identifier
        def add_heredoc_comma(corrector, node)
          return unless heredoc?(node)

          corrector.insert_after(node.child_nodes.last, ',')
        end

        def heredoc?(node)
          node.child_nodes.last.loc.is_a?(Parser::Source::Map::Heredoc)
        end
      end
    end
  end
end
