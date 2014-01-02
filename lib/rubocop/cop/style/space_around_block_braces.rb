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
        include ConfigurableEnforcedStyle
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

          check_outside(left_brace)
          check_inside(node, left_brace, right_brace)
        end

        private

        def check_outside(left_brace)
          if range_with_surrounding_space(left_brace).source.start_with?('{')
            add_offence(left_brace, left_brace,
                        'Space missing to the left of {.')
          end
        end

        def check_inside(node, left_brace, right_brace)
          sb = node.loc.expression.source_buffer

          if left_brace.end_pos == right_brace.begin_pos
            if style_for_empty_braces == :space
              offence(sb, left_brace.begin_pos, right_brace.end_pos,
                      'Space missing inside empty braces.')
            end
          else
            range = Parser::Source::Range.new(sb, left_brace.end_pos,
                                              right_brace.begin_pos)
            inner = range.source
            unless inner =~ /\n/
              if inner =~ /\S/
                braces_with_contents_inside(node, inner, sb)
              elsif style_for_empty_braces == :no_space
                offence(sb, range.begin_pos, range.end_pos,
                        'Space inside empty braces detected.')
              end
            end
          end
        end

        def braces_with_contents_inside(node, inner, sb)
          _method, args, _body = *node
          left_brace, right_brace = node.loc.begin, node.loc.end
          pipe = args.loc.begin

          if inner =~ /^\S/
            no_space_inside_left_brace(left_brace, pipe, sb)
          else
            space_inside_left_brace(left_brace, pipe, sb)
          end

          if inner =~ /\S$/
            no_space(sb, right_brace.begin_pos, right_brace.end_pos,
                     'Space missing inside }.')
          else
            space_inside_right_brace(right_brace, sb)
          end
        end

        def no_space_inside_left_brace(left_brace, pipe, sb)
          if pipe
            if left_brace.end_pos == pipe.begin_pos &&
                cop_config['SpaceBeforeBlockParameters']
              offence(sb, left_brace.begin_pos, pipe.end_pos,
                      'Space between { and | missing.')
            end
          else
            # We indicate the position after the left brace. Otherwise it's
            # difficult to distinguish between space missing to the left and to
            # the right of the brace in autocorrect.
            no_space(sb, left_brace.end_pos, left_brace.end_pos + 1,
                     'Space missing inside {.')
          end
        end

        def space_inside_left_brace(left_brace, pipe, sb)
          if pipe
            unless cop_config['SpaceBeforeBlockParameters']
              offence(sb, left_brace.end_pos, pipe.begin_pos,
                      'Space between { and | detected.')
            end
          else
            brace_with_space = range_with_surrounding_space(left_brace, :right)
            space(sb, brace_with_space.begin_pos + 1, brace_with_space.end_pos,
                  'Space inside { detected.')
          end
        end

        def space_inside_right_brace(right_brace, sb)
          brace_with_space = range_with_surrounding_space(right_brace, :left)
          space(sb, brace_with_space.begin_pos, brace_with_space.end_pos - 1,
                'Space inside } detected.')
        end

        def no_space(sb, begin_pos, end_pos, msg)
          if style == :space_inside_braces
            offence(sb, begin_pos, end_pos, msg) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        def space(sb, begin_pos, end_pos, msg)
          if style == :no_space_inside_braces
            offence(sb, begin_pos, end_pos, msg) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        def offence(sb, begin_pos, end_pos, msg)
          range = Parser::Source::Range.new(sb, begin_pos, end_pos)
          add_offence(range, range, msg) { yield if block_given? }
        end

        def style_for_empty_braces
          case cop_config['EnforcedStyleForEmptyBraces']
          when 'space'    then :space
          when 'no_space' then :no_space
          else fail 'Unknown EnforcedStyleForEmptyBraces selected!'
          end
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
