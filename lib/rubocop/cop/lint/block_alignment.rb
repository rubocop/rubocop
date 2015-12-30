# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks whether the end keywords are aligned properly for do
      # end blocks.
      #
      # @example
      #
      #   variable = lambda do |i|
      #     i
      #   end
      class BlockAlignment < Cop
        MSG = '`%s` at %d, %d is not aligned with `%s` at %d, %d%s.'

        def_node_matcher :block_end_align_target?, <<-PATTERN
          {assignment?
           splat
           and
           or
           (send _ :<<  ...)
           (send equal?(%1) !:[] ...)}
        PATTERN

        def on_block(node)
          check_block_alignment(start_for_block_node(node), node)
        end

        private

        def start_for_block_node(block_node)
          # Which node should we align the 'end' with?
          result = block_node

          while (parent = result.parent)
            break if !parent || !parent.loc
            break if parent.loc.line != block_node.loc.line &&
                     !parent.masgn_type?
            break unless block_end_align_target?(parent, result)
            result = parent
          end

          # In offense message, we want to show the assignment LHS rather than
          # the entire assignment
          result, = *result while result.op_asgn_type? || result.masgn_type?
          result
        end

        def check_block_alignment(start_node, block_node)
          end_loc = block_node.loc.end
          return unless begins_its_line?(end_loc)

          start_loc = start_node.loc.expression
          return unless start_loc.column != end_loc.column

          do_loc = block_node.loc.begin # Actually it's either do or {.

          # We've found that "end" is not aligned with the start node (which
          # can be a block, a variable assignment, etc). But we also allow
          # the "end" to be aligned with the start of the line where the "do"
          # is, which is a style some people use in multi-line chains of
          # blocks.
          match = /\S.*/.match(do_loc.source_line)
          indentation_of_do_line = match.begin(0)
          return unless end_loc.column != indentation_of_do_line

          add_offense(block_node,
                      end_loc,
                      format(MSG, end_loc.source, end_loc.line, end_loc.column,
                             start_loc.source.lines.to_a.first.chomp,
                             start_loc.line, start_loc.column,
                             alt_start_msg(match, start_loc, do_loc,
                                           indentation_of_do_line)))
        end

        def alt_start_msg(match, start_loc, do_loc, indentation_of_do_line)
          if start_loc.line == do_loc.line &&
             start_loc.column == indentation_of_do_line
            ''
          else
            " or `#{match[0]}` at #{do_loc.line}, #{indentation_of_do_line}"
          end
        end

        def autocorrect(node)
          ancestor_node = start_for_block_node(node)
          source = node.loc.expression.source_buffer

          lambda do |corrector|
            start_col = (ancestor_node || node).loc.expression.column
            starting_position_of_block_end = node.loc.end.begin_pos
            end_col = node.loc.end.column

            if end_col < start_col
              delta = start_col - end_col
              corrector.insert_before(node.loc.end, ' ' * delta)
            elsif end_col > start_col
              range_start = starting_position_of_block_end + start_col - end_col
              range = Parser::Source::Range.new(source, range_start,
                                                starting_position_of_block_end)
              corrector.remove(range)
            end
          end
        end
      end
    end
  end
end
