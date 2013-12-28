# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks that braces used for hash literals have or don't have
      # surrounding space depending on configuration.
      class SpaceInsideHashLiteralBraces < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = 'Space inside %s.'

        def investigate(processed_source)
          return unless processed_source.ast
          tokens = processed_source.tokens

          on_node(:hash, processed_source.ast) do |hash|
            b_ix = index_of_first_token(hash)
            if tokens[b_ix].type == :tLBRACE # Hash literal with braces?
              e_ix = index_of_last_token(hash)
              check(tokens[b_ix], tokens[b_ix + 1])
              check(tokens[e_ix - 1], tokens[e_ix]) unless b_ix == e_ix - 1
            end
          end
        end

        private

        def check(t1, t2)
          # No offence if line break inside.
          return if t1.pos.line < t2.pos.line

          is_empty_braces = t1.text == '{' && t2.text == '}'
          expect_space = if is_empty_braces
                           cop_config['EnforcedStyleForEmptyBraces'] == 'space'
                         else
                           style == :space
                         end
          if offence?(t1, t2, expect_space)
            brace = (t1.text == '{' ? t1 : t2).pos
            range = expect_space ? brace : space_range(brace)
            add_offence(range, range, message(brace, is_empty_braces,
                                              expect_space)) do
              opposite_style_detected
            end
          else
            correct_style_detected
          end
        end

        def offence?(t1, t2, expect_space)
          has_space = space_between?(t1, t2)
          expect_space ? !has_space : has_space
        end

        def message(brace, is_empty_braces, expect_space)
          inside_what = if is_empty_braces
                          'empty hash literal braces'
                        else
                          brace.source
                        end
          problem = expect_space ? 'missing' : 'detected'
          sprintf(MSG, "#{inside_what} #{problem}")
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            case range.source
            when /\s/ then corrector.remove(range)
            when '{' then corrector.insert_after(range, ' ')
            else corrector.insert_before(range, ' ')
            end
          end
        end

        def space_range(token_range)
          if token_range.source == '{'
            range_of_space_to_the_right(token_range)
          else
            range_of_space_to_the_left(token_range)
          end
        end

        def range_of_space_to_the_right(range)
          src = range.source_buffer.source
          end_pos = range.end_pos
          end_pos += 1 while src[end_pos] =~ /[ \t]/
          Parser::Source::Range.new(range.source_buffer,
                                    range.begin_pos + 1, end_pos)
        end

        def range_of_space_to_the_left(range)
          src = range.source_buffer.source
          begin_pos = range.begin_pos
          begin_pos -= 1 while src[begin_pos - 1] =~ /[ \t]/
          Parser::Source::Range.new(range.source_buffer, begin_pos,
                                    range.end_pos - 1)
        end
      end
    end
  end
end
