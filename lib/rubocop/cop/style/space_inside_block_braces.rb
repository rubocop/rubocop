# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks that block braces have or don't have surrounding space inside
      # them on configuration. For blocks taking parameters, it checks that the
      # left brace has or doesn't have trailing space depending on
      # configuration.
      class SpaceInsideBlockBraces < Cop
        include ConfigurableEnforcedStyle
        include SurroundingSpace

        def on_block(node)
          return if node.loc.begin.is?('do') # No braces.

          # If braces are on separate lines, and the BlockDelimiters cop is
          # enabled, those braces will be changed to do..end by the user or by
          # auto-correct, so reporting space issues is not useful, and it
          # creates auto-correct conflicts.
          if config.for_cop('Style/BlockDelimiters')['Enabled'] &&
             block_length(node) > 0
            return
          end

          left_brace = node.loc.begin
          right_brace = node.loc.end

          check_inside(node, left_brace, right_brace)
        end

        private

        def check_inside(node, left_brace, right_brace)
          sb = node.source_range.source_buffer

          if left_brace.end_pos == right_brace.begin_pos
            adjacent_braces(sb, left_brace, right_brace)
          elsif left_brace.line == right_brace.line
            range = Parser::Source::Range.new(sb, left_brace.end_pos,
                                              right_brace.begin_pos)
            inner = range.source

            if inner =~ /\S/
              braces_with_contents_inside(node, inner, sb)
            elsif style_for_empty_braces == :no_space
              offense(sb, range.begin_pos, range.end_pos,
                      'Space inside empty braces detected.')
            end
          end
        end

        def adjacent_braces(sb, left_brace, right_brace)
          return if style_for_empty_braces != :space

          offense(sb, left_brace.begin_pos, right_brace.end_pos,
                  'Space missing inside empty braces.')
        end

        def braces_with_contents_inside(node, inner, sb)
          _method, args, _body = *node
          left_brace = node.loc.begin
          right_brace = node.loc.end
          args_delimiter = args.loc.begin # Can be ( | or nil.

          if inner =~ /^\S/
            no_space_inside_left_brace(left_brace, args_delimiter, sb)
          else
            space_inside_left_brace(left_brace, args_delimiter, sb)
          end

          if inner =~ /\S$/
            no_space(sb, right_brace.begin_pos, right_brace.end_pos,
                     'Space missing inside }.')
          else
            space_inside_right_brace(right_brace, sb)
          end
        end

        def no_space_inside_left_brace(left_brace, args_delimiter, sb)
          if pipe?(args_delimiter)
            if left_brace.end_pos == args_delimiter.begin_pos &&
               cop_config['SpaceBeforeBlockParameters']
              offense(sb, left_brace.begin_pos, args_delimiter.end_pos,
                      'Space between { and | missing.') do
                opposite_style_detected
              end
            end
          else
            # We indicate the position after the left brace. Otherwise it's
            # difficult to distinguish between space missing to the left and to
            # the right of the brace in autocorrect.
            no_space(sb, left_brace.end_pos, left_brace.end_pos + 1,
                     'Space missing inside {.')
          end
        end

        def space_inside_left_brace(left_brace, args_delimiter, sb)
          if pipe?(args_delimiter)
            unless cop_config['SpaceBeforeBlockParameters']
              offense(sb, left_brace.end_pos, args_delimiter.begin_pos,
                      'Space between { and | detected.') do
                opposite_style_detected
              end
            end
          else
            brace_with_space = range_with_surrounding_space(left_brace, :right)
            space(sb, brace_with_space.begin_pos + 1, brace_with_space.end_pos,
                  'Space inside { detected.')
          end
        end

        def pipe?(args_delimiter)
          args_delimiter && args_delimiter.is?('|')
        end

        def space_inside_right_brace(right_brace, sb)
          brace_with_space = range_with_surrounding_space(right_brace, :left)
          space(sb, brace_with_space.begin_pos, brace_with_space.end_pos - 1,
                'Space inside } detected.')
        end

        def no_space(sb, begin_pos, end_pos, msg)
          if style == :space
            offense(sb, begin_pos, end_pos, msg) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        def space(sb, begin_pos, end_pos, msg)
          if style == :no_space
            offense(sb, begin_pos, end_pos, msg) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        def offense(sb, begin_pos, end_pos, msg)
          range = Parser::Source::Range.new(sb, begin_pos, end_pos)
          add_offense(range, range, msg) { yield if block_given? }
        end

        def style_for_empty_braces
          case cop_config['EnforcedStyleForEmptyBraces']
          when 'space'    then :space
          when 'no_space' then :no_space
          else fail 'Unknown EnforcedStyleForEmptyBraces selected!'
          end
        end

        def autocorrect(range)
          lambda do |corrector|
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
