# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks the spacing inside and after block parameters pipes. Line breaks
      # inside parameter pipes are checked by `Layout/MultilineBlockLayout` and
      # not by this cop.
      #
      # @example EnforcedStyleInsidePipes: no_space (default)
      #   # bad
      #   {}.each { | x,  y |puts x }
      #   ->( x,  y ) { puts x }
      #
      #   # good
      #   {}.each { |x, y| puts x }
      #   ->(x, y) { puts x }
      #
      # @example EnforcedStyleInsidePipes: space
      #   # bad
      #   {}.each { |x,  y| puts x }
      #   ->(x,  y) { puts x }
      #
      #   # good
      #   {}.each { | x, y | puts x }
      #   ->( x, y ) { puts x }
      class SpaceAroundBlockParameters < Base
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector

        def on_block(node)
          arguments = node.arguments

          return unless node.arguments? && pipes?(arguments)

          check_inside_pipes(arguments)
          check_after_closing_pipe(arguments) if node.body
          check_each_arg(arguments)
        end

        private

        def pipes(arguments)
          [arguments.loc.begin, arguments.loc.end]
        end

        def pipes?(arguments)
          pipes(arguments).none?(&:nil?)
        end

        def style_parameter_name
          'EnforcedStyleInsidePipes'
        end

        def check_inside_pipes(arguments)
          opening_pipe, closing_pipe = pipes(arguments)

          if style == :no_space
            check_no_space_style_inside_pipes(arguments.children,
                                              opening_pipe,
                                              closing_pipe)
          elsif style == :space
            check_space_style_inside_pipes(arguments.children,
                                           opening_pipe,
                                           closing_pipe)
          end
        end

        def check_after_closing_pipe(arguments)
          _opening_pipe, closing_pipe = pipes(arguments)
          block = arguments.parent

          check_space(closing_pipe.end_pos, block.body.source_range.begin_pos,
                      closing_pipe, 'after closing `|`')
        end

        def check_no_space_style_inside_pipes(args, opening_pipe, closing_pipe)
          first = args.first.source_range
          last = args.last.source_range

          check_no_space(opening_pipe.end_pos, first.begin_pos,
                         'Space before first')
          check_no_space(last_end_pos_inside_pipes(last),
                         closing_pipe.begin_pos, 'Space after last')
        end

        def check_space_style_inside_pipes(args, opening_pipe, closing_pipe)
          check_opening_pipe_space(args, opening_pipe)
          check_closing_pipe_space(args, closing_pipe)
        end

        def check_opening_pipe_space(args, opening_pipe)
          first_arg = args.first
          range = first_arg.source_range

          check_space(opening_pipe.end_pos, range.begin_pos, range,
                      'before first block parameter', first_arg)
          check_no_space(opening_pipe.end_pos, range.begin_pos - 1,
                         'Extra space before first')
        end

        def check_closing_pipe_space(args, closing_pipe)
          last         = args.last.source_range
          last_end_pos = last_end_pos_inside_pipes(last)

          check_space(last_end_pos, closing_pipe.begin_pos, last,
                      'after last block parameter')
          check_no_space(last_end_pos + 1, closing_pipe.begin_pos,
                         'Extra space after last')
        end

        def last_end_pos_inside_pipes(range)
          pos = range.end_pos
          range.source_buffer.source[pos] == ',' ? pos + 1 : pos
        end

        def check_each_arg(args)
          args.children.each do |arg|
            check_arg(arg)
          end
        end

        def check_arg(arg)
          arg.children.each { |a| check_arg(a) } if arg.mlhs_type?

          expr = arg.source_range
          check_no_space(
            range_with_surrounding_space(range: expr, side: :left).begin_pos,
            expr.begin_pos - 1,
            'Extra space before'
          )
        end

        def check_space(space_begin_pos, space_end_pos, range, msg, node = nil)
          return if space_begin_pos != space_end_pos

          target = node || range
          message = "Space #{msg} missing."
          add_offense(target, message: message) do |corrector|
            if node
              corrector.insert_before(node, ' ')
            else
              corrector.insert_after(target, ' ')
            end
          end
        end

        def check_no_space(space_begin_pos, space_end_pos, msg)
          return if space_begin_pos >= space_end_pos

          range = range_between(space_begin_pos, space_end_pos)
          return if range.source.include?("\n")

          message = "#{msg} block parameter detected."
          add_offense(range, message: message) do |corrector|
            corrector.remove(range)
          end
        end
      end
    end
  end
end
