# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that block braces have or don't have surrounding space inside
      # them on configuration. For blocks taking parameters, it checks that the
      # left brace has or doesn't have trailing space depending on
      # configuration.
      #
      # @example EnforcedStyle: space (default)
      #   # The `space` style enforces that block braces have
      #   # surrounding space.
      #
      #   # bad
      #   some_array.each {puts e}
      #
      #   # good
      #   some_array.each { puts e }
      #
      # @example EnforcedStyle: no_space
      #   # The `no_space` style enforces that block braces don't
      #   # have surrounding space.
      #
      #   # bad
      #   some_array.each { puts e }
      #
      #   # good
      #   some_array.each {puts e}
      #
      #
      # @example EnforcedStyleForEmptyBraces: no_space (default)
      #   # The `no_space` EnforcedStyleForEmptyBraces style enforces that
      #   # block braces don't have a space in between when empty.
      #
      #   # bad
      #   some_array.each {   }
      #   some_array.each {  }
      #   some_array.each { }
      #
      #   # good
      #   some_array.each {}
      #
      # @example EnforcedStyleForEmptyBraces: space
      #   # The `space` EnforcedStyleForEmptyBraces style enforces that
      #   # block braces have at least a spece in between when empty.
      #
      #   # bad
      #   some_array.each {}
      #
      #   # good
      #   some_array.each { }
      #   some_array.each {  }
      #   some_array.each {   }
      #
      #
      # @example SpaceBeforeBlockParameters: true (default)
      #   # The SpaceBeforeBlockParameters style set to `true` enforces that
      #   # there is a space between `{` and `|`. Overrides `EnforcedStyle`
      #   # if there is a conflict.
      #
      #   # bad
      #   [1, 2, 3].each {|n| n * 2 }
      #
      #   # good
      #   [1, 2, 3].each { |n| n * 2 }
      #
      # @example SpaceBeforeBlockParameters: true
      #   # The SpaceBeforeBlockParameters style set to `false` enforces that
      #   # there is no space between `{` and `|`. Overrides `EnforcedStyle`
      #   # if there is a conflict.
      #
      #   # bad
      #   [1, 2, 3].each { |n| n * 2 }
      #
      #   # good
      #   [1, 2, 3].each {|n| n * 2 }
      #
      class SpaceInsideBlockBraces < Cop
        include ConfigurableEnforcedStyle
        include SurroundingSpace
        include RangeHelp

        def on_block(node)
          return if node.keywords?

          left_brace = node.loc.begin
          right_brace = node.loc.end

          check_inside(node, left_brace, right_brace)
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

        private

        def check_inside(node, left_brace, right_brace)
          if left_brace.end_pos == right_brace.begin_pos
            adjacent_braces(left_brace, right_brace)
          else
            range = range_between(left_brace.end_pos, right_brace.begin_pos)
            inner = range.source

            if inner =~ /\S/
              braces_with_contents_inside(node, inner)
            elsif style_for_empty_braces == :no_space
              offense(range.begin_pos, range.end_pos,
                      'Space inside empty braces detected.')
            end
          end
        end

        def adjacent_braces(left_brace, right_brace)
          return if style_for_empty_braces != :space

          offense(left_brace.begin_pos, right_brace.end_pos,
                  'Space missing inside empty braces.')
        end

        def braces_with_contents_inside(node, inner)
          args_delimiter = node.arguments.loc.begin # Can be ( | or nil.

          check_left_brace(inner, node.loc.begin, args_delimiter)
          check_right_brace(inner, node.loc.end, node.single_line?)
        end

        def check_left_brace(inner, left_brace, args_delimiter)
          if inner =~ /\A\S/
            no_space_inside_left_brace(left_brace, args_delimiter)
          else
            space_inside_left_brace(left_brace, args_delimiter)
          end
        end

        def check_right_brace(inner, right_brace, single_line)
          if single_line && inner =~ /\S$/
            no_space(right_brace.begin_pos, right_brace.end_pos,
                     'Space missing inside }.')
          else
            space_inside_right_brace(right_brace)
          end
        end

        def no_space_inside_left_brace(left_brace, args_delimiter)
          if pipe?(args_delimiter)
            if left_brace.end_pos == args_delimiter.begin_pos &&
               cop_config['SpaceBeforeBlockParameters']
              offense(left_brace.begin_pos, args_delimiter.end_pos,
                      'Space between { and | missing.') do
                opposite_style_detected
              end
            end
          else
            # We indicate the position after the left brace. Otherwise it's
            # difficult to distinguish between space missing to the left and to
            # the right of the brace in autocorrect.
            no_space(left_brace.end_pos, left_brace.end_pos + 1,
                     'Space missing inside {.')
          end
        end

        def space_inside_left_brace(left_brace, args_delimiter)
          if pipe?(args_delimiter)
            unless cop_config['SpaceBeforeBlockParameters']
              offense(left_brace.end_pos, args_delimiter.begin_pos,
                      'Space between { and | detected.') do
                opposite_style_detected
              end
            end
          else
            brace_with_space = range_with_surrounding_space(range: left_brace,
                                                            side: :right)
            space(brace_with_space.begin_pos + 1, brace_with_space.end_pos,
                  'Space inside { detected.')
          end
        end

        def pipe?(args_delimiter)
          args_delimiter && args_delimiter.is?('|')
        end

        def space_inside_right_brace(right_brace)
          brace_with_space = range_with_surrounding_space(range: right_brace,
                                                          side: :left)
          space(brace_with_space.begin_pos, brace_with_space.end_pos - 1,
                'Space inside } detected.')
        end

        def no_space(begin_pos, end_pos, msg)
          if style == :space
            offense(begin_pos, end_pos, msg) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        def space(begin_pos, end_pos, msg)
          if style == :no_space
            offense(begin_pos, end_pos, msg) { opposite_style_detected }
          else
            correct_style_detected
          end
        end

        def offense(begin_pos, end_pos, msg, &block)
          range = range_between(begin_pos, end_pos)
          add_offense(range, location: range, message: msg, &block)
        end

        def style_for_empty_braces
          case cop_config['EnforcedStyleForEmptyBraces']
          when 'space'    then :space
          when 'no_space' then :no_space
          else raise 'Unknown EnforcedStyleForEmptyBraces selected!'
          end
        end
      end
    end
  end
end
