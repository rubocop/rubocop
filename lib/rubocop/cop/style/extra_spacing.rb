# encoding: utf-8

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

        MSG = 'Unnecessary spacing detected.'

        def investigate(processed_source)
          ast = processed_source.ast

          processed_source.tokens.each_cons(2) do |t1, t2|
            next if t2.type == :tNL
            next if t1.pos.line != t2.pos.line
            next if t2.pos.begin_pos - 1 <= t1.pos.end_pos
            next if allow_for_alignment? && aligned_token?(t2)

            start_pos = t1.pos.end_pos
            next if ignored_ranges(ast).find { |r| r.include?(start_pos) }

            end_pos = t2.pos.begin_pos - 1
            range = Parser::Source::Range.new(processed_source.buffer,
                                              start_pos, end_pos)
            # Unary + doesn't appear as a token and needs special handling.
            next if unary_plus_non_offense?(range)

            add_offense(range, range, MSG)
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end

        private

        def aligned_token?(token)
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
            key.loc.expression.end_pos...value.loc.expression.begin_pos
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
      end
    end
  end
end
