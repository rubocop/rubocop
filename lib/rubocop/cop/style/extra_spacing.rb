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
        MSG = 'Unnecessary spacing detected.'

        def investigate(processed_source)
          ast = processed_source.ast
          ignored_ranges = ast ? ignored_ranges(ast) : []

          processed_source.tokens.each_cons(2) do |t1, t2|
            next if t2.type == :tNL
            next if t1.pos.line != t2.pos.line
            next if t2.pos.begin_pos - 1 <= t1.pos.end_pos
            next if allow_for_alignment? && aligned_with_something?(t2)
            start_pos = t1.pos.end_pos
            end_pos = t2.pos.begin_pos - 1
            range = Parser::Source::Range.new(processed_source.buffer,
                                              start_pos, end_pos)
            add_offense(range, range, MSG) unless ignored_ranges.include?(range)
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end

        private

        # Returns an array of ranges that should not be reported. It's the
        # extra spaces between the separators (: or =>) and values in a hash,
        # since those are handled by the Style/AlignHash cop.
        def ignored_ranges(ast)
          ranges = []
          on_node(:pair, ast) do |pair|
            _, value = *pair
            ranges <<
              Parser::Source::Range.new(processed_source.buffer,
                                        pair.loc.operator.end_pos,
                                        value.loc.expression.begin_pos - 1)
          end
          ranges
        end

        def allow_for_alignment?
          cop_config['AllowForAlignment']
        end

        def aligned_with_something?(token)
          return aligned_comments?(token) if token.type == :tCOMMENT

          pre = (token.pos.line - 2).downto(0)
          post = token.pos.line.upto(processed_source.lines.size - 1)
          return true if aligned_with?(pre, token) || aligned_with?(post, token)

          # If no aligned token was found, search for an aligned token on the
          # nearest line with the same indentation as the checked line.
          base_indentation = processed_source.lines[token.pos.line - 1] =~ /\S/
          aligned_with?(pre, token, base_indentation) ||
            aligned_with?(post, token, base_indentation)
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

        # Returns true if the previous or next line, not counting empty or
        # comment lines, contains a token that's aligned with the given
        # token. If base_indentation is given, lines with different indentation
        # than the base indentation are also skipped.
        def aligned_with?(indices_to_check, token, base_indentation = nil)
          indices_to_check.each do |ix|
            next if comment_lines.include?(ix + 1)
            line = processed_source.lines[ix]
            next if line.strip.empty?
            if base_indentation
              indentation = line =~ /\S/
              next if indentation != base_indentation
            end
            return (aligned_words?(token, line) ||
                    aligned_assignments?(token, line) ||
                    aligned_same_character?(token, line))
          end
          false # No line to check was found.
        end

        def comment_lines
          @comment_lines ||=
            begin
              whole_line_comments = processed_source.comments.select do |c|
                begins_its_line?(c.loc.expression)
              end
              whole_line_comments.map(&:loc).map(&:line)
            end
        end

        def aligned_words?(token, line)
          line[token.pos.column - 1, 2] =~ /\s\S/
        end

        def aligned_assignments?(token, line)
          token.type == :tOP_ASGN &&
            line[token.pos.column + token.text.length] == '='
        end

        def aligned_same_character?(token, line)
          line[token.pos.column] == token.text.to_s[0]
        end
      end
    end
  end
end
