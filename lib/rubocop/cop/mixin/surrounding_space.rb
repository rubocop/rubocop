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

      def tokens(node)
        processed_source.tokens.select do |token|
          token.end_pos <= node.source_range.end_pos &&
            token.begin_pos >= node.source_range.begin_pos
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

      def no_space_corrector(corrector, left_token, right_token)
        if left_token.space_after?
          range = side_space_range(range: left_token.pos, side: :right)
          corrector.remove(range)
        end
        return unless right_token.space_before?
        range = side_space_range(range: right_token.pos, side: :left)
        corrector.remove(range)
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

      def space_corrector(corrector, left_token, right_token)
        unless left_token.space_after?
          corrector.insert_after(left_token.pos, ' ')
        end
        return if right_token.space_before?
        corrector.insert_before(right_token.pos, ' ')
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
    end
  end
end
