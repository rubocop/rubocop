# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks whether the end keyword of a block is properly
      # aligned.
      #
      # With an enforced style of `flexible` the `end` keyword can be
      # aligned with an operator, the block expression or the beginning
      # of the `do` line.
      #
      # With an enforced style of `at_least_do` the `end` keyword must
      # be aligned with the same rules as the `flexible` style, but must
      # be indented at least as far as the beginning of the `do` line.
      #
      # With an enforced style of `strictly_do` the `end` keyword must
      # be aligned with the beginning of the `do` line.
      #
      # @example
      #
      #   # always good
      #   variable = lambda do |i|
      #     i
      #   end
      #
      #   # accepted with `flexible`
      #   def foo(bar)
      #     bar.get_stuffs
      #        .reject do |stuff|
      #       stuff.foo
      #     end
      #   end
      #
      #   # enforced with `strictly_do` and `at_least_do`
      #   # accepted with `flexible`
      #   def foo(bar)
      #     bar.get_stuffs
      #        .reject do |stuff|
      #          stuff.foo
      #        end
      #   end
      #
      #   # enforced with `strictly_do`
      #   # accepted with `at_least_do` and `flexible`
      #   variable =
      #     Hash[+foo { |_|
      #       bar
      #     }]
      class BlockAlignment < Cop
        include ConfigurableEnforcedStyle

        MSG = '`%s` at %d, %d is not aligned with `%s` at %d, %d%s.'.freeze

        def_node_matcher :block_end_align_target?, <<-PATTERN
          {assignment?
           splat
           and
           or
           (send _ :<<  ...)
           (send equal?(%1) !:[] ...)}
        PATTERN

        # Align the block end with a node.
        class NodeAligner
          def initialize(node)
            @node = node
          end

          def column
            @node.source_range.column
          end

          def source
            @node.source_range.source.lines.to_a.first.chomp
          end

          def line
            @node.source_range.line
          end
        end

        # Align the block end with a line.
        class LineAligner
          def initialize(node)
            @node = node
          end

          def column
            whitespace = @node.source_line[/^\s+/]

            whitespace ? whitespace.size : 0
          end

          def source
            # @node.source_range.source.lines.to_a[line].chomp
            @node.source_line.sub(/^\s+/, '')
          end

          def line
            # @begin.line - @node.loc.expression.line
            @node.line
          end
        end

        def on_block(node)
          check_block_alignment(start_for_block_node(node), node)
        end

        private

        # rubocop:disable Metrics/CyclomaticComplexity
        def start_for_block_node(block_node)
          do_align = LineAligner.new(block_node.loc.begin)

          return do_align if style == :strictly_do

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

          if style == :at_least_do && result.loc.column < do_align.column
            do_align
          else
            NodeAligner.new(result)
          end
        end

        def check_block_alignment(start, block_node)
          end_loc = block_node.loc.end
          return unless begins_its_line?(end_loc)

          return unless start.column != end_loc.column

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
                             start.source,
                             start.line, start.column,
                             alt_start_msg(match, start, do_loc,
                                           indentation_of_do_line)))
        end

        def alt_start_msg(match, start, do_loc, indentation_of_do_line)
          if start.line == do_loc.line &&
             start.column == indentation_of_do_line
            ''
          else
            " or `#{match[0]}` at #{do_loc.line}, #{indentation_of_do_line}"
          end
        end

        def autocorrect(node)
          ancestor_node = start_for_block_node(node)
          source = node.source_range.source_buffer

          lambda do |corrector|
            start_col = ancestor_node && ancestor_node.column
            start_col ||= node.source_range.column
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
