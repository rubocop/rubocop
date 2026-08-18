# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for extra/unnecessary whitespace.
      #
      # @example
      #
      #   # good if AllowForAlignment is true
      #   name      = "RuboCop"
      #   # Some comment and an empty line
      #
      #   website  += "/rubocop/rubocop" unless cond
      #   puts        "rubocop"          if     debug
      #
      #   # bad for any configuration
      #   set_app("RuboCop")
      #   website  = "https://github.com/rubocop/rubocop"
      #
      #   # good only if AllowBeforeTrailingComments is true
      #   object.method(arg)  # this is a comment
      #
      #   # good even if AllowBeforeTrailingComments is false or not set
      #   object.method(arg) # this is a comment
      #
      #   # good with either AllowBeforeTrailingComments or AllowForAlignment
      #   object.method(arg)         # this is a comment
      #   another_object.method(arg) # this is another comment
      #   some_object.method(arg)    # this is some comment
      class ExtraSpacing < Base
        extend AutoCorrector
        include PrecedingFollowingAlignment
        include RangeHelp

        MSG_UNNECESSARY = 'Unnecessary spacing detected.'
        MSG_UNALIGNED_ASGN = '`=` is not aligned with the %<location>s assignment.'

        def on_new_investigation
          return if processed_source.blank?

          @aligned_comments = aligned_locations(processed_source.comments.map(&:loc))
          @corrected = Set.new if force_equal_sign_alignment?
          prepare_alignment_data

          processed_source.tokens.each_cons(2) do |token1, token2|
            check_tokens(processed_source.ast, token1, token2)
          end
        end

        private

        def aligned_locations(locs)
          return [] if locs.empty?

          aligned = Set.new
          locs.each_cons(2) do |loc1, loc2|
            aligned << loc1.line << loc2.line if loc1.column == loc2.column
          end
          aligned
        end

        def check_tokens(ast, token1, token2)
          return if token2.type == :tNL

          if force_equal_sign_alignment? && assignment_tokens.include?(token2)
            check_assignment(token2)
          else
            check_other(token1, token2, ast)
          end
        end

        def check_assignment(token)
          return unless aligned_with_preceding_equals_operator(token) == :no

          message = format(MSG_UNALIGNED_ASGN, location: 'preceding')
          add_offense(token.pos, message: message) do |corrector|
            align_equal_signs(token.pos, corrector)
          end
        end

        def check_other(token1, token2, ast)
          return false if allow_for_trailing_comments? && token2.text.start_with?('#')

          extra_space_range(token1, token2) do |range|
            next if ignored_range?(ast, range.begin_pos)

            add_offense(range, message: MSG_UNNECESSARY) { |corrector| corrector.remove(range) }
          end
        end

        def extra_space_range(token1, token2)
          return if token1.line != token2.line

          start_pos = token1.end_pos
          end_pos = token2.begin_pos - 1
          return if end_pos <= start_pos

          return if allow_for_alignment? && aligned_tok?(token1, token2)

          yield range_between(start_pos, end_pos)
        end

        def aligned_tok?(previous_token, token)
          if token.comment?
            @aligned_comments.include?(token.line)
          else
            aligned_with_something?(token.pos) &&
              (ASSIGNMENT_OR_COMPARISON_TOKENS.include?(token.type) ||
               spacing_varies?(previous_token, token))
          end
        end

        def spacing_varies?(previous_token, token)
          by_column, typed = group_profile(token.line)
          column = token.pos.column
          lines, spacings = typed[[column, token.type]]
          entries = by_column[column]

          if lines.size > 1
            uniform_alignment_allowed?(token, lines, spacings)
          elsif entries.size > 1
            distinct_spacings(entries).size > 1
          else
            nearest_spacing_varies?(previous_token, token)
          end
        end

        def uniform_alignment_allowed?(token, lines, spacings)
          return @alignment_verdicts[lines] if @alignment_verdicts.key?(lines)

          @alignment_verdicts[lines] =
            spacings.uniq.size > 1 || aligned_on_other_column?(token, lines)
        end

        def aligned_on_other_column?(token, lines)
          line_set = Set.new(lines)
          by_column, = group_profile(token.line)

          by_column.any? do |column, entries|
            next false if column == token.pos.column

            shared = entries.filter_map { |line, spacing| spacing if line_set.include?(line) }
            shared.uniq.size > 1
          end
        end

        def distinct_spacings(entries)
          entries.map(&:last).uniq
        end

        def group_profile(line_number)
          group = alignment_lines(line_number)

          @group_profiles[group] ||= build_group_profile(group)
        end

        def build_group_profile(group)
          by_column = Hash.new { |hash, key| hash[key] = [] }
          typed = Hash.new { |hash, key| hash[key] = [[], []] }

          group.each { |line| record_line_spacings(by_column, typed, line) }

          [by_column, typed]
        end

        def record_line_spacings(by_column, typed, line)
          @tokens_by_line[line]&.each_cons(2) do |previous_token, token|
            spacing = token.begin_pos - previous_token.end_pos
            by_column[token.pos.column] << [line, spacing]
            lines, spacings = typed[[token.pos.column, token.type]]
            lines << line
            spacings << spacing
          end
        end

        def nearest_spacing_varies?(previous_token, token)
          spacing = token.begin_pos - previous_token.end_pos
          line_ranges = [(token.line - 1).downto(1),
                         (token.line + 1).upto(processed_source.lines.length)]

          line_ranges.any? do |line_numbers|
            nearest_spacing_differs?(line_numbers, token, spacing)
          end
        end

        def nearest_spacing_differs?(line_numbers, token, spacing)
          line_numbers.each do |line|
            break if definition_boundary_lines.include?(line)
            next if aligned_comment_lines.include?(line)

            other_spacing = spacing_before_token_at(line, token.pos.column)
            return other_spacing != spacing if other_spacing
          end

          false
        end

        def spacing_before_token_at(line_number, column)
          tokens = @tokens_by_line[line_number]
          index = tokens&.index { |token| token.pos.column == column }
          return unless index&.positive?

          tokens[index].begin_pos - tokens[index - 1].end_pos
        end

        def prepare_alignment_data
          @group_profiles = {}.compare_by_identity
          @alignment_verdicts = {}.compare_by_identity
          @tokens_by_line = processed_source.tokens.group_by(&:line)
        end

        def ignored_range?(ast, start_pos)
          ignored_ranges(ast).any? { |r| r.include?(start_pos) }
        end

        # Returns an array of ranges that should not be reported. It's the
        # extra spaces between the keys and values in a multiline hash,
        # since those are handled by the Layout/HashAlignment cop.
        def ignored_ranges(ast)
          return [] unless ast

          @ignored_ranges ||= begin
            ranges = []
            on_node(:pair, ast) do |pair|
              next if pair.parent.single_line?

              key, value = *pair
              ranges << (key.source_range.end_pos...value.source_range.begin_pos)
            end
            ranges
          end
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

          if diff.positive?
            corrector.insert_before(token.pos, ' ' * diff)
          elsif diff.negative?
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

        def allow_for_trailing_comments?
          cop_config['AllowBeforeTrailingComments']
        end
      end
    end
  end
end
