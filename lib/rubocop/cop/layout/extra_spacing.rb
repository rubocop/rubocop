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
            @asgn_tokens = assignment_tokens
            @asgn_lines  = @asgn_tokens.map(&:line)
            # Don't attempt to correct the same = more than once
            @corrected   = Set.new
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

        def assignment_tokens
          tokens = processed_source.tokens.select(&:equal_sign?)
          # we don't want to operate on equals signs which are part of an
          #   optarg in a method definition
          # e.g.: def method(optarg = default_val); end
          tokens = remove_optarg_equals(tokens, processed_source)

          # Only attempt to align the first = on each line
          Set.new(tokens.uniq(&:line))
        end

        def check_tokens(ast, token1, token2)
          return if token2.type == :tNL

          if force_equal_sign_alignment? && @asgn_tokens.include?(token2)
            check_assignment(token2)
          else
            check_other(token1, token2, ast)
          end
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def check_assignment(token)
          token_line_indent              = processed_source
                                           .line_indentation(token.line)

          preceding_line_range           = token.line.downto(1)
          preceding_assignment_lines     = \
            relevant_assignment_lines(preceding_line_range)
          preceding_relevant_line_number = preceding_assignment_lines[1]

          return unless preceding_relevant_line_number

          preceding_relevant_indent = \
            processed_source
            .line_indentation(preceding_relevant_line_number)

          return if preceding_relevant_indent < token_line_indent

          assignment_line = processed_source
                            .lines[preceding_relevant_line_number - 1]
          message         = format(MSG_UNALIGNED_ASGN, location: 'preceding')

          return unless assignment_line
          return if aligned_assignment?(token.pos, assignment_line)

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
          tokens = @asgn_tokens.select { |t| lines.include?(t.line) }

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

        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
        def relevant_assignment_lines(line_range)
          result               = []
          original_line_indent = processed_source
                                 .line_indentation(line_range.first)
          previous_line_indent_at_level = true

          line_range.each do |line_number|
            current_line_indent = processed_source.line_indentation(line_number)
            blank_line          = processed_source.lines[line_number - 1].blank?

            if (current_line_indent < original_line_indent && !blank_line) ||
               (previous_line_indent_at_level && blank_line)
              break
            end

            result << line_number if @asgn_lines.include?(line_number) &&
                                     current_line_indent == original_line_indent

            unless blank_line
              previous_line_indent_at_level = \
                current_line_indent == original_line_indent
            end
          end

          result
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength

        def align_column(asgn_token)
          # if we removed unneeded spaces from the beginning of this =,
          # what column would it end from?
          line    = processed_source.lines[asgn_token.line - 1]
          leading = line[0...asgn_token.column]
          spaces  = leading.size - (leading =~ / *\Z/)
          asgn_token.pos.last_column - spaces + 1
        end

        def remove_optarg_equals(asgn_tokens, processed_source)
          optargs    = processed_source.ast.each_node(:optarg)
          optarg_eql = optargs.map { |o| o.loc.operator.begin_pos }.to_set
          asgn_tokens.reject { |t| optarg_eql.include?(t.begin_pos) }
        end
      end
    end
  end
end
