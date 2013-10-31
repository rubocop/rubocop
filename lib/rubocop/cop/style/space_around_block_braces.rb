# encoding: utf-8

# rubocop:disable SymbolName

module Rubocop
  module Cop
    module Style
      # Checks that block braces have or don't have surrounding space depending
      # on configuration. For blocks taking parameters, it checks that the left
      # brace has or doesn't have trailing space depending on configuration.
      class SpaceAroundBlockBraces < Cop
        include SurroundingSpace

        def investigate(processed_source)
          return unless processed_source.ast
          @processed_source = processed_source

          processed_source.tokens.each_cons(2) do |t1, t2|
            next if ([t1.pos, t2.pos] - positions_not_to_check).size < 2

            type1, type2 = t1.type, t2.type
            if [:tLCURLY, :tRCURLY].include?(type2)
              check(t1, t2)
            elsif type1 == :tLCURLY
              if type2 == :tPIPE
                check_pipe(t1, t2)
              else
                check(t1, t2)
              end
            end
          end
        end

        def positions_not_to_check
          @positions_not_to_check ||= begin
            positions = []
            ast = @processed_source.ast
            tokens = @processed_source.tokens

            on_node(:hash, ast) do |hash|
              b_ix = index_of_first_token(hash)
              e_ix = index_of_last_token(hash)
              positions << tokens[b_ix].pos << tokens[e_ix].pos
            end

            # TODO: Check braces inside string/symbol/regexp/xstr
            #   interpolation.
            on_node([:dstr, :dsym, :regexp, :xstr], ast) do |s|
              b_ix = index_of_first_token(s)
              e_ix = index_of_last_token(s)
              tokens[b_ix..e_ix].each do |t|
                positions << t.pos if t.type == :tRCURLY
              end
            end

            positions
          end
        end

        def check(t1, t2)
          if t2.text == '{'
            check_space_outside_left_brace(t1, t2)
          elsif t1.text == '{' && t2.text == '}'
            check_empty_braces(t1, t2)
          elsif cop_config['EnforcedStyle'] == 'space_inside_braces'
            check_space_inside_braces(t1, t2)
          else
            check_no_space_inside_braces(t1, t2)
          end
        end

        def check_empty_braces(t1, t2)
          if cop_config['EnforcedStyleForEmptyBraces'] == 'space'
            check_space_inside_braces(t1, t2)
          else
            check_no_space_inside_braces(t1, t2)
          end
        end

        def check_space_inside_braces(t1, t2)
          unless space_between?(t1, t2)
            token, what = problem_details(t1, t2)
            convention(token.pos, token.pos, "Space missing inside #{what}.")
          end
        end

        def check_no_space_inside_braces(t1, t2)
          if space_between?(t1, t2)
            token, what = problem_details(t1, t2)
            s = space_range(token)
            convention(s, s, "Space inside #{what} detected.")
          end
        end

        def problem_details(t1, t2)
          if t1.text == '{'
            token = t1
            what = t2.text == '}' ? 'empty braces' : '{'
          else
            token = t2
            what = '}'
          end
          [token, what]
        end

        def check_space_outside_left_brace(t1, t2)
          if t2.text == '{' && !space_between?(t1, t2)
            convention(t1.pos, t2.pos, 'Space missing to the left of {.')
          end
        end

        def check_pipe(t1, t2)
          if cop_config['SpaceBeforeBlockParameters']
            unless space_between?(t1, t2)
              convention(t2.pos, t1.pos, 'Space between { and | missing.')
            end
          elsif space_between?(t1, t2)
            s = space_range(t1)
            convention(s, s, 'Space between { and | detected.')
          end
        end

        def space_range(token)
          src = @processed_source.buffer.source
          if token.text == '{'
            b = token.pos.begin_pos + 1
            e = b + 1
            e += 1 while src[e] =~ /\s/
          else
            e = token.pos.begin_pos
            b = e - 1
            b -= 1 while src[b - 1] =~ /\s/
          end
          Parser::Source::Range.new(@processed_source.buffer, b, e)
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            case range.source
            when '}', '|' then corrector.insert_before(range, ' ')
            when ' '      then corrector.remove(range)
            else               corrector.insert_after(range, ' ')
            end
          end
        end
      end
    end
  end
end
