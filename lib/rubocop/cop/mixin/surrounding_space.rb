# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking and correcting surrounding whitespace.
    module SurroundingSpace
      NO_SPACE_COMMAND = 'Do not use'.freeze
      SPACE_COMMAND = 'Use'.freeze

      private

      def side_space_range(range:, side:)
        buffer = @processed_source.buffer
        src = buffer.source

        begin_pos = range.begin_pos
        end_pos = range.end_pos
        if side == :left
          begin_pos = reposition(src, begin_pos, -1)
          end_pos -= 1
        end
        if side == :right
          begin_pos += 1
          end_pos = reposition(src, end_pos, 1)
        end
        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end

      def index_of_first_token(node)
        range = node.source_range
        token_table[range.line][range.column]
      end

      def index_of_last_token(node)
        range = node.source_range
        table_row = token_table[range.last_line]
        (0...range.last_column).reverse_each do |c|
          ix = table_row[c]
          return ix if ix
        end
      end

      def token_table
        @token_table ||= begin
          table = {}
          @processed_source.tokens.each_with_index do |t, ix|
            table[t.line] ||= {}
            table[t.line][t.column] = ix
          end
          table
        end
      end

      def no_space_offenses(node, # rubocop:disable Metrics/ParameterLists
                            left_token,
                            right_token,
                            message,
                            start_ok: false,
                            end_ok: false)
        if extra_space?(left_token, :left) && !start_ok
          space_offense(node, left_token, :right, message, NO_SPACE_COMMAND)
        end
        return if !extra_space?(right_token, :right) || end_ok
        space_offense(node, right_token, :left, message, NO_SPACE_COMMAND)
      end

      def space_offenses(node, # rubocop:disable Metrics/ParameterLists
                         left_token,
                         right_token,
                         message,
                         start_ok: false,
                         end_ok: false)
        unless extra_space?(left_token, :left) || start_ok
          space_offense(node, left_token, :none, message, SPACE_COMMAND)
        end
        return if extra_space?(right_token, :right) || end_ok
        space_offense(node, right_token, :none, message, SPACE_COMMAND)
      end

      def extra_space?(token, side)
        return false unless token
        if side == :left
          String(token.space_after?) == ' '
        else
          String(token.space_before?) == ' '
        end
      end

      def reposition(src, pos, step)
        offset = step == -1 ? -1 : 0
        pos += step while src[pos + offset] =~ /[ \t]/
        pos < 0 ? 0 : pos
      end

      def space_offense(node, token, side, message, command)
        range = side_space_range(range: token.pos, side: side)
        add_offense(node, location: range,
                          message: format(message, command: command))
      end

      def empty_offenses(node, left, right, message)
        if offending_empty_space?(empty_config, left, right)
          empty_offense(node, message, 'Use one')
        end
        return unless offending_empty_no_space?(empty_config, left, right)
        empty_offense(node, message, 'Do not use')
      end

      def empty_offense(node, message, command)
        add_offense(node, message: format(message, command: command))
      end

      def empty_brackets?(left_bracket_token, right_bracket_token)
        left_index = processed_source.tokens.index(left_bracket_token)
        right_index = processed_source.tokens.index(right_bracket_token)
        right_index && left_index == right_index - 1
      end

      def offending_empty_space?(config, left_token, right_token)
        config == 'space' && !space_between?(left_token, right_token)
      end

      def offending_empty_no_space?(config, left_token, right_token)
        config == 'no_space' && !no_space_between?(left_token, right_token)
      end

      def space_between?(left_bracket_token, right_bracket_token)
        left_bracket_token.end_pos + 1 == right_bracket_token.begin_pos
      end

      def no_space_between?(left_bracket_token, right_bracket_token)
        left_bracket_token.end_pos == right_bracket_token.begin_pos
      end
    end
  end
end
