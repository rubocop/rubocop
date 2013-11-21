# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks that block braces have or don't have surrounding space depending
      # on configuration. For blocks taking parameters, it checks that the left
      # brace has or doesn't have trailing space depending on configuration.
      # Also checks that the left brace is preceded by a space and this is not
      # configurable.
      class SpaceAroundBlockBraces < Cop
        include SurroundingSpace

        def on_block(node)
          return if node.loc.begin.is?('do') # No braces.

          # If braces are on separate lines, and the Blocks cop is enabled,
          # those braces will be changed to do..end by the user or by
          # auto-correct, so reporting space issues is not useful, and it
          # creates auto-correct conflicts.
          if config.for_cop('Blocks')['Enabled'] && Util.block_length(node) > 0
            return
          end

          left_brace, right_brace = node.loc.begin, node.loc.end
          sb = node.loc.expression.source_buffer

          if range_with_surrounding_space(left_brace).source.start_with?('{')
            no_space_before_left_brace(left_brace, sb)
          end

          if left_brace.end_pos == right_brace.begin_pos
            no_space_inside_empty_braces(left_brace, right_brace, sb)
          else
            range = Parser::Source::Range.new(sb, left_brace.end_pos,
                                              right_brace.begin_pos)
            inner = range.source
            if inner =~ /^[ \t]*$/
              space_inside_empty_braces(range)
            else
              braces_with_contents_inside(node, inner)
            end
          end
        end

        private

        def braces_with_contents_inside(node, inner)
          _method, args, _body = *node
          left_brace, right_brace = node.loc.begin, node.loc.end
          pipe = args.loc.begin
          sb = node.loc.expression.source_buffer

          if inner =~ /^\S/
            no_space_inside_left_brace(left_brace, pipe, sb)
          else
            space_inside_left_brace(left_brace, pipe, sb)
          end

          if inner =~ /\S$/
            no_space_inside_right_brace(right_brace)
          else
            space_inside_right_brace(right_brace, sb)
          end
        end

        def no_space_before_left_brace(left_brace, sb)
          convention(left_brace, left_brace, 'Space missing to the left of {.')
        end

        def no_space_inside_empty_braces(left_brace, right_brace, sb)
          if style_for_empty_braces == :space
            range = Parser::Source::Range.new(sb, left_brace.begin_pos,
                                              right_brace.end_pos)
            convention(range, range, 'Space missing inside empty braces.')
          end
        end

        def space_inside_empty_braces(range)
          if style_for_empty_braces == :no_space
            convention(range, range, 'Space inside empty braces detected.')
          end
        end

        def no_space_inside_left_brace(left_brace, pipe, sb)
          if pipe
            if left_brace.end_pos == pipe.begin_pos
              if style_for_block_parameters == :space
                range = Parser::Source::Range.new(sb, left_brace.begin_pos,
                                                  pipe.end_pos)
                convention(range, range, 'Space between { and | missing.')
              end
            end
          elsif style == :space_inside_braces
            # We indicate the position after the left brace. Otherwise it's
            # difficult to distinguish between space missing to the left and to
            # the right of the brace in autocorrect.
            range = Parser::Source::Range.new(sb, left_brace.end_pos,
                                              left_brace.end_pos + 1)
            convention(range, range, 'Space missing inside {.')
          end
        end

        def space_inside_left_brace(left_brace, pipe, sb)
          if pipe
            if style_for_block_parameters == :no_space
              range = Parser::Source::Range.new(sb, left_brace.end_pos,
                                                pipe.begin_pos)
              convention(range, range, 'Space between { and | detected.')
            end
          elsif style == :no_space_inside_braces
            brace_with_space = range_with_surrounding_space(left_brace, :right)
            range = Parser::Source::Range.new(sb,
                                              brace_with_space.begin_pos + 1,
                                              brace_with_space.end_pos)
            convention(range, range, 'Space inside { detected.')
          end
        end

        def no_space_inside_right_brace(right_brace)
          if style == :space_inside_braces
            convention(right_brace, right_brace, 'Space missing inside }.')
          end
        end

        def space_inside_right_brace(right_brace, sb)
          if style == :no_space_inside_braces
            brace_with_space = range_with_surrounding_space(right_brace, :left)
            range = Parser::Source::Range.new(sb,
                                              brace_with_space.begin_pos,
                                              brace_with_space.end_pos - 1)
            convention(range, range, 'Space inside } detected.')
          end
        end

        def style
          case cop_config['EnforcedStyle']
          when 'space_inside_braces'    then :space_inside_braces
          when 'no_space_inside_braces' then :no_space_inside_braces
          else fail 'Unknown EnforcedStyle selected!'
          end
        end

        def style_for_empty_braces
          case cop_config['EnforcedStyleForEmptyBraces']
          when 'space'    then :space
          when 'no_space' then :no_space
          else fail 'Unknown EnforcedStyleForEmptyBraces selected!'
          end
        end

        def style_for_block_parameters
          cop_config['SpaceBeforeBlockParameters'] ? :space : :no_space
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            case range.source
            when /\s/ then corrector.remove(range)
            when '{}' then corrector.replace(range, '{ }')
            when '{|' then corrector.replace(range, '{ |')
            else           corrector.insert_before(range, ' ')
            end
          end
        end
      end
    end
  end
end
