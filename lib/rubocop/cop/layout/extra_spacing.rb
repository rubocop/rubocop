# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Layout
      # This cop checks for extra/unnecessary whitespace.
      #
      # @example
      #
      #   # good if AllowForAlignment is true
      #   name      = "RuboCop"
      #   # Some comment and an empty line
      #
      #   website  += "/bbatsov/rubocop" unless cond
      #   puts        "rubocop"          if     debug
      #
      #   # bad for any configuration
      #   set_app("RuboCop")
      #   website  = "https://github.com/bbatsov/rubocop"
      class ExtraSpacing < Cop
        include PrecedingFollowingAlignment
        include RangeHelp

        MSG_UNNECESSARY = 'Unnecessary spacing detected.'.freeze
        MSG_UNALIGNED_ASGN = '`=` is not aligned with the %<location>s ' \
                             'assignment.'.freeze

        def investigate(processed_source)
          return if processed_source.blank?

          if force_equal_sign_alignment?
            @corrected = Set.new
          end

          processed_source.tokens.each_cons(2) do |token1, token2|
            check_tokens(processed_source.ast, token1, token2)
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            if range.source.end_with?('=')
              align_equal_signs(range, corrector)
            else
              corrector.remove(range)
            end
          end
        end

        private

        def check_tokens(ast, token1, token2)
          return if token2.type == :tNL

          if force_equal_sign_alignment? && assignment_tokens.include?(token2)
            check_assignment(token2)
          else
            check_other(token1, token2, ast)
          end
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def check_assignment(token)
          return if aligned_with_operator?(token)

          message = format(MSG_UNALIGNED_ASGN, location: 'preceding')
          add_offense(token.pos, location: token.pos, message: message)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def check_other(token1, token2, ast)
          extra_space_range(token1, token2) do |range|
            # Unary + doesn't appear as a token and needs special handling.
            next if ignored_range?(ast, range.begin_pos)
            next if unary_plus_non_offense?(range)

            add_offense(range, location: range, message: MSG_UNNECESSARY)
          end
        end

        def extra_space_range(token1, token2)
          return if token1.line != token2.line

          start_pos = token1.end_pos
          end_pos = token2.begin_pos - 1
          return if end_pos <= start_pos

          return if allow_for_alignment? && aligned_tok?(token2)

          yield range_between(start_pos, end_pos)
        end

        def aligned_tok?(token)
          if token.comment?
            aligned_comments?(token)
          else
            aligned_with_something?(token.pos)
          end
        end

        def ignored_range?(ast, start_pos)
          ignored_ranges(ast).any? { |r| r.include?(start_pos) }
        end

        def unary_plus_non_offense?(range)
          range.resize(range.size + 1).source =~ /^ ?\+$/
        end

        # Returns an array of ranges that should not be reported. It's the
        # extra spaces between the keys and values in a multiline hash,
        # since those are handled by the Style/AlignHash cop.
        def ignored_ranges(ast)
          return [] unless ast

          @ignored_ranges ||= on_node(:pair, ast).map do |pair|
            next if pair.parent.single_line?

            key, value = *pair
            key.source_range.end_pos...value.source_range.begin_pos
          end.compact
        end

        def aligned_comments?(comment_token)
          ix = processed_source.comments.index do |comment|
            comment.loc.expression.begin_pos == comment_token.begin_pos
          end
          aligned_with_previous_comment?(ix) || aligned_with_next_comment?(ix)
        end

        def aligned_with_previous_comment?(index)
          index > 0 && comment_column(index - 1) == comment_column(index)
        end

        def aligned_with_next_comment?(index)
          index < processed_source.comments.length - 1 &&
            comment_column(index + 1) == comment_column(index)
        end

        def comment_column(index)
          processed_source.comments[index].loc.column
        end

        def force_equal_sign_alignment?
          cop_config['ForceEqualSignAlignment']
        end

        def align_equal_signs(range, corrector)
          lines  = all_relevant_assignment_lines(range.line)
          tokens = assignment_tokens.select { |t| lines.include?(t.line) }

          columns  = tokens.map { |t| align_column(t) }
          align_to = columns.max

          tokens.each { |token| align_equal_sign(corrector, token, align_to) }
        end

        def align_equal_sign(corrector, token, align_to)
          return unless @corrected.add?(token)

          diff = align_to - token.pos.last_column

          if diff > 0
            corrector.insert_before(token.pos, ' ' * diff)
          elsif diff < 0
            corrector.remove_preceding(token.pos, -diff)
          end
        end

        def all_relevant_assignment_lines(line_number)
          last_line_number = processed_source.lines.size

          (
            relevant_assignment_lines(line_number.downto(1)) +
            relevant_assignment_lines(line_number.upto(last_line_number))
          )
            .uniq
            .sort
        end

        def align_column(asgn_token)
          # if we removed unneeded spaces from the beginning of this =,
          # what column would it end from?
          line    = processed_source.lines[asgn_token.line - 1]
          leading = line[0...asgn_token.column]
          spaces  = leading.size - (leading =~ / *\Z/)
          asgn_token.pos.last_column - spaces + 1
        end
      end
    end
  end
end
