# encoding: utf-8

require 'set'

module RuboCop
  module Cop
    module Style
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

        MSG_UNNECESSARY = 'Unnecessary spacing detected.'
        MSG_UNALIGNED_ASGN = '`=` is not aligned with the %s assignment.'

        def investigate(processed_source)
          ast = processed_source.ast

          if force_equal_sign_alignment?
            @asgn_tokens = processed_source.tokens.select { |t| equal_sign?(t) }
            # Only attempt to align the first = on each line
            @asgn_tokens = Set.new(@asgn_tokens.uniq { |t| t.pos.line })
            @asgn_lines  = @asgn_tokens.map { |t| t.pos.line }
            # Don't attempt to correct the same = more than once
            @corrected   = Set.new
          end

          processed_source.tokens.each_cons(2) do |t1, t2|
            next if t2.type == :tNL

            if force_equal_sign_alignment? &&
               @asgn_tokens.include?(t2) &&
               (@asgn_lines.include?(t2.pos.line - 1) ||
                @asgn_lines.include?(t2.pos.line + 1))
              check_assignment(t2)
            else
              check_other(t1, t2, ast)
            end
          end
        end

        def correct(range)
          return :uncorrected unless autocorrect?

          if range.source.end_with?('=')
            align_equal_sign(range)
          else
            correction { |corrector| corrector.remove(range) }
          end
          :corrected
        end

        def support_autocorrect?
          true
        end

        private

        def check_assignment(token)
          # minus 2 is because pos.line is zero-based
          line = processed_source.lines[token.pos.line - 2]
          return if aligned_assignment?(token.pos, line)

          preceding  = @asgn_lines.include?(token.pos.line - 1)
          align_with = preceding ? 'preceding' : 'following'
          message    = format(MSG_UNALIGNED_ASGN, align_with)
          add_offense(token.pos, token.pos, message)
        end

        def check_other(t1, t2, ast)
          return if t1.pos.line != t2.pos.line
          return if t2.pos.begin_pos - 1 <= t1.pos.end_pos
          return if allow_for_alignment? && aligned_tok?(t2)

          start_pos = t1.pos.end_pos
          return if ignored_ranges(ast).find { |r| r.include?(start_pos) }

          end_pos = t2.pos.begin_pos - 1
          range = Parser::Source::Range.new(processed_source.buffer,
                                            start_pos, end_pos)
          # Unary + doesn't appear as a token and needs special handling.
          return if unary_plus_non_offense?(range)

          add_offense(range, range, MSG_UNNECESSARY)
        end

        def aligned_tok?(token)
          if token.type == :tCOMMENT
            aligned_comments?(token)
          else
            aligned_with_something?(token.pos)
          end
        end

        def unary_plus_non_offense?(range)
          range.resize(range.size + 1).source =~ /^ ?\+$/
        end

        # Returns an array of ranges that should not be reported. It's the
        # extra spaces between the keys and values in a hash, since those are
        # handled by the Style/AlignHash cop.
        def ignored_ranges(ast)
          return [] unless ast

          @ignored_ranges ||= on_node(:pair, ast).map do |pair|
            key, value = *pair
            key.source_range.end_pos...value.source_range.begin_pos
          end
        end

        def aligned_comments?(token)
          ix = processed_source.comments.index do |c|
            c.loc.expression.begin_pos == token.pos.begin_pos
          end
          aligned_with_previous_comment?(ix) || aligned_with_next_comment?(ix)
        end

        def aligned_with_previous_comment?(ix)
          ix > 0 && comment_column(ix - 1) == comment_column(ix)
        end

        def aligned_with_next_comment?(ix)
          ix < processed_source.comments.length - 1 &&
            comment_column(ix + 1) == comment_column(ix)
        end

        def comment_column(ix)
          processed_source.comments[ix].loc.column
        end

        def force_equal_sign_alignment?
          cop_config['ForceEqualSignAlignment']
        end

        def equal_sign?(token)
          token.type == :tEQL || token.type == :tOP_ASGN
        end

        def align_equal_sign(range)
          lines  = contiguous_assignment_lines(range)
          tokens = @asgn_tokens.select { |t| lines.include?(t.pos.line) }

          columns  = tokens.map { |t| align_column(t) }
          align_to = columns.max

          tokens.each do |token|
            next unless @corrected.add?(token)
            diff = align_to - token.pos.last_column

            if diff > 0
              correction { |corr| corr.insert_before(token.pos, ' ' * diff) }
            elsif diff < 0
              correction { |corr| corr.remove_preceding(token.pos, -diff) }
            end
          end
        end

        def contiguous_assignment_lines(range)
          result = [range.line]

          range.line.downto(1) do |lineno|
            @asgn_lines.include?(lineno) ? result << lineno : break
          end
          range.line.upto(processed_source.lines.size) do |lineno|
            @asgn_lines.include?(lineno) ? result << lineno : break
          end

          result.sort!
        end

        def align_column(asgn_token)
          # if we removed unneeded spaces from the beginning of this =,
          # what column would it end from?
          line    = processed_source.lines[asgn_token.pos.line - 1]
          leading = line[0...asgn_token.pos.column]
          spaces  = leading.size - (leading =~ / *\Z/)
          asgn_token.pos.last_column - spaces + 1
        end

        def correction(&block)
          @corrections << block
        end
      end
    end
  end
end
