# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for the placement of the closing parenthesis
      # in a method call that passes a HEREDOC string as an argument.
      # It should be placed at the end of the line containing the
      # opening HEREDOC tag.
      #
      # @example
      #   # bad
      #
      #      foo(<<-SQL
      #        bar
      #      SQL
      #      )
      #
      #      foo(<<-SQL, 123, <<-NOSQL,
      #        bar
      #      SQL
      #        baz
      #      NOSQL
      #      )
      #
      #      foo(
      #        bar(<<-SQL
      #          baz
      #        SQL
      #        ),
      #        123,
      #      )
      #
      #   # good
      #
      #      foo(<<-SQL)
      #        bar
      #      SQL
      #
      #      foo(<<-SQL, 123, <<-NOSQL)
      #        bar
      #      SQL
      #        baz
      #      NOSQL
      #
      #      foo(
      #        bar(<<-SQL),
      #          baz
      #        SQL
      #        123,
      #      )
      #
      class HeredocArgumentClosingParenthesis < Cop
        include RangeHelp

        MSG = 'Put the closing parenthesis for a method call with a ' \
        'HEREDOC parameter on the same line as the HEREDOC opening.'

        def on_send(node)
          heredoc_arg = extract_heredoc_argument(node)
          return unless heredoc_arg

          outermost_send = outermost_send_on_same_line(heredoc_arg)
          return unless outermost_send
          return unless outermost_send.loc.end
          return unless heredoc_arg.first_line != outermost_send.loc.end.line

          add_offense(outermost_send, location: :end)
        end

        # Autocorrection note:
        #
        # Commas are a bit tricky to handle when the method call is
        # embedded in another expression. Here's an example:
        #
        # [
        #   first_array_value,
        #   foo(<<-SQL, 123, 456,
        #     SELECT * FROM db
        #   SQL
        #   ),
        #   third_array_value,
        # ]
        #
        # The "internal" trailing comma is after `456`.
        # The "external" trailing comma is after `)`.
        #
        # To autocorrect, we remove the latter, and move the former up:
        #
        # [
        #   first_array_value,
        #   foo(<<-SQL, 123, 456),
        #     SELECT * FROM db
        #   SQL
        #   third_array_value,
        # ]
        def autocorrect(node)
          lambda do |corrector|
            fix_closing_parenthesis(node, corrector)

            if internal_trailing_comma?(node)
              remove_internal_trailing_comma(node, corrector)
            end

            if external_trailing_comma?(node)
              fix_external_trailing_comma(node, corrector)
            end
          end
        end

        def self.autocorrect_incompatible_with
          [Style::TrailingCommaInArguments]
        end

        private

        def outermost_send_on_same_line(heredoc)
          previous = heredoc
          current = previous.parent
          until send_missing_closing_parens?(current, previous, heredoc)
            previous = current
            current = current.parent
            return unless previous && current
          end
          current
        end

        def send_missing_closing_parens?(parent, child, heredoc)
          parent&.call_type? &&
            parent.arguments.include?(child) &&
            parent.loc.begin &&
            parent.loc.end.line != heredoc.last_line
        end

        def extract_heredoc_argument(node)
          node.arguments.find do |arg_node|
            extract_heredoc(arg_node)
          end
        end

        def extract_heredoc(node)
          return node if heredoc_node?(node)
          return node.receiver if single_line_send_with_heredoc_receiver?(node)

          return unless node.hash_type?

          node.values.find do |v|
            heredoc = extract_heredoc(v)
            return heredoc if heredoc
          end
        end

        def heredoc_node?(node)
          node.respond_to?(:heredoc?) && node.heredoc?
        end

        def single_line_send_with_heredoc_receiver?(node)
          return false unless node.send_type?
          return false unless heredoc_node?(node.receiver)

          node.receiver.location.heredoc_end.end_pos > node.source_range.end_pos
        end

        # Closing parenthesis helpers.

        def fix_closing_parenthesis(node, corrector)
          remove_incorrect_closing_paren(node, corrector)
          add_correct_closing_paren(node, corrector)
        end

        def add_correct_closing_paren(node, corrector)
          corrector.insert_after(node.arguments.last.source_range, ')')
        end

        def remove_incorrect_closing_paren(node, corrector)
          corrector.remove(
            range_between(
              incorrect_parenthesis_removal_begin(node),
              incorrect_parenthesis_removal_end(node)
            )
          )
        end

        def incorrect_parenthesis_removal_begin(node)
          end_pos = node.source_range.end_pos
          if safe_to_remove_line_containing_closing_paren?(node)
            last_line_length = node.source.scan(/\n(.*)$/).last[0].size
            end_pos - last_line_length - 1 # Add one for the line break itself.
          else
            end_pos - 1 # Just the `)` at the end of the string
          end
        end

        def safe_to_remove_line_containing_closing_paren?(node)
          last_line = processed_source[node.loc.end.line - 1]
          # Safe to remove if last line only contains `)`, `,`, and whitespace.
          last_line.match(/^[ ]*\)[ ]{0,20},{0,1}[ ]*$/)
        end

        def incorrect_parenthesis_removal_end(node)
          end_pos = node.source_range.end_pos
          if processed_source.buffer.source[end_pos] == ','
            end_pos + 1
          else
            end_pos
          end
        end

        # Internal trailing comma helpers.

        def remove_internal_trailing_comma(node, corrector)
          offset = internal_trailing_comma_offset_from_last_arg(node)
          last_arg_end_pos = node.children.last.source_range.end_pos
          corrector.remove(
            range_between(
              last_arg_end_pos,
              last_arg_end_pos + offset
            )
          )
        end

        def internal_trailing_comma?(node)
          !internal_trailing_comma_offset_from_last_arg(node).nil?
        end

        # Returns nil if no trailing internal comma.
        def internal_trailing_comma_offset_from_last_arg(node)
          source_after_last_arg = range_between(
            node.children.last.source_range.end_pos,
            node.loc.end.begin_pos
          ).source

          first_comma_offset = source_after_last_arg.index(',')
          first_new_line_offset = source_after_last_arg.index("\n")
          return if first_comma_offset.nil?
          return if first_new_line_offset.nil?
          return if first_comma_offset > first_new_line_offset

          first_comma_offset + 1
        end

        # External trailing comma helpers.

        def fix_external_trailing_comma(node, corrector)
          remove_incorrect_external_trailing_comma(node, corrector)
          add_correct_external_trailing_comma(node, corrector)
        end

        def add_correct_external_trailing_comma(node, corrector)
          return unless external_trailing_comma?(node)

          corrector.insert_after(node.arguments.last.source_range, ',')
        end

        def remove_incorrect_external_trailing_comma(node, corrector)
          end_pos = node.source_range.end_pos
          return unless external_trailing_comma?(node)

          corrector.remove(
            range_between(
              end_pos,
              end_pos + external_trailing_comma_offset_from_loc_end(node)
            )
          )
        end

        def external_trailing_comma?(node)
          !external_trailing_comma_offset_from_loc_end(node).nil?
        end

        # Returns nil if no trailing external comma.
        def external_trailing_comma_offset_from_loc_end(node)
          end_pos = node.source_range.end_pos
          offset = 0
          limit = 20
          offset += 1 while offset < limit && space?(end_pos + offset)
          char = processed_source.buffer.source[end_pos + offset]
          return unless char == ','

          offset + 1 # Add one to include the comma.
        end

        def space?(pos)
          processed_source.buffer.source[pos] == ' '
        end
      end
    end
  end
end
