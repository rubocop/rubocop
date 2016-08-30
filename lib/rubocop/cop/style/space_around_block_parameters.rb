# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks the spacing inside and after block parameters pipes.
      #
      # @example
      #
      #   # bad
      #   {}.each { | x,  y |puts x }
      #
      #   # good
      #   {}.each { |x, y| puts x }
      class SpaceAroundBlockParameters < Cop
        include ConfigurableEnforcedStyle

        def on_block(node)
          _method, args, body = *node
          opening_pipe = args.loc.begin
          closing_pipe = args.loc.end
          return unless !args.children.empty? && opening_pipe

          check_inside_pipes(args.children, opening_pipe, closing_pipe)

          if body
            check_space(closing_pipe.end_pos, body.source_range.begin_pos,
                        closing_pipe, 'after closing `|`')
          end

          check_each_arg(args)
        end

        private

        def parameter_name
          'EnforcedStyleInsidePipes'
        end

        def check_inside_pipes(args, opening_pipe, closing_pipe)
          if style == :no_space
            check_no_space_style_inside_pipes(args, opening_pipe, closing_pipe)
          elsif style == :space
            check_space_style_inside_pipes(args, opening_pipe, closing_pipe)
          end
        end

        def check_no_space_style_inside_pipes(args, opening_pipe, closing_pipe)
          first = args.first.source_range
          last = args.last.source_range

          check_no_space(opening_pipe.end_pos, first.begin_pos,
                         'Space before first')
          check_no_space(last_end_pos_inside_pipes(last.end_pos),
                         closing_pipe.begin_pos, 'Space after last')
        end

        def check_space_style_inside_pipes(args, opening_pipe, closing_pipe)
          first = args.first.source_range
          last = args.last.source_range
          last_end_pos = last_end_pos_inside_pipes(last.end_pos)

          check_space(opening_pipe.end_pos, first.begin_pos, first,
                      'before first block parameter')
          check_space(last_end_pos, closing_pipe.begin_pos, last,
                      'after last block parameter')
          check_no_space(opening_pipe.end_pos, first.begin_pos - 1,
                         'Extra space before first')
          check_no_space(last_end_pos + 1, closing_pipe.begin_pos,
                         'Extra space after last')
        end

        def last_end_pos_inside_pipes(pos)
          processed_source.buffer.source[pos] == ',' ? pos + 1 : pos
        end

        def check_each_arg(args)
          args.children.butfirst.each do |arg|
            expr = arg.source_range
            check_no_space(range_with_surrounding_space(expr, :left).begin_pos,
                           expr.begin_pos - 1, 'Extra space before')
          end
        end

        def check_space(space_begin_pos, space_end_pos, range, msg)
          return if space_begin_pos != space_end_pos

          add_offense(range, range, "Space #{msg} missing.")
        end

        def check_no_space(space_begin_pos, space_end_pos, msg)
          return if space_begin_pos >= space_end_pos

          range = range_between(space_begin_pos, space_end_pos)
          add_offense(range, range, "#{msg} block parameter detected.")
        end

        def autocorrect(range)
          lambda do |corrector|
            case range.source
            when /^\s+$/ then corrector.remove(range)
            else              corrector.insert_after(range, ' ')
            end
          end
        end
      end
    end
  end
end
