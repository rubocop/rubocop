# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks whether method definitions are
      # separated by one empty line.
      #
      # `NumberOfEmptyLines` can be an integer (default is 1) or
      # an array (e.g. [1, 2]) to specify a minimum and maximum
      # number of empty lines permitted.
      #
      # `AllowAdjacentOneLineDefs` configures whether adjacent
      # one-line method definitions are considered an offense.
      #
      # @example
      #
      #   # bad
      #   def a
      #   end
      #   def b
      #   end
      #
      # @example
      #
      #   # good
      #   def a
      #   end
      #
      #   def b
      #   end
      class EmptyLineBetweenDefs < Cop
        include RangeHelp

        MSG = 'Use empty lines between method definitions.'.freeze

        def self.autocorrect_incompatible_with
          [Layout::EmptyLines]
        end

        # We operate on `begin` nodes, instead of using `OnMethodDef`,
        # so that we can walk over pairs of consecutive nodes and
        # efficiently access a node's predecessor; #prev_node ends up
        # doing a linear scan over siblings, so we don't want to call
        # it on each def.
        def on_begin(node)
          node.children.each_cons(2) do |prev, n|
            nodes = [prev, n]
            check_defs(nodes) if nodes.all?(&method(:def_node?))
          end
        end

        def check_defs(nodes)
          return if blank_lines_between?(*nodes)
          return if multiple_blank_lines_groups?(*nodes)
          return if nodes.all?(&:single_line?) &&
                    cop_config['AllowAdjacentOneLineDefs']

          add_offense(nodes.last, location: :keyword)
        end

        def autocorrect(node)
          prev_def = prev_node(node)

          # finds position of first newline
          end_pos = prev_def.loc.end.end_pos
          source_buffer = prev_def.loc.end.source_buffer
          newline_pos = source_buffer.source.index("\n", end_pos)

          count = blank_lines_count_between(prev_def, node)

          if count > maximum_empty_lines
            autocorrect_remove_lines(newline_pos, count)
          else
            autocorrect_insert_lines(newline_pos, count)
          end
        end

        private

        def def_node?(node)
          return unless node
          node.def_type? || node.defs_type?
        end

        def multiple_blank_lines_groups?(first_def_node, second_def_node)
          lines = lines_between_defs(first_def_node, second_def_node)
          blank_start = lines.each_index.select { |i| lines[i].blank? }.max
          non_blank_end = lines.each_index.reject { |i| lines[i].blank? }.min
          return false if blank_start.nil? || non_blank_end.nil?
          blank_start > non_blank_end
        end

        def blank_lines_between?(first_def_node, second_def_node)
          count = blank_lines_count_between(first_def_node, second_def_node)
          (minimum_empty_lines..maximum_empty_lines).cover?(count)
        end

        def blank_lines_count_between(first_def_node, second_def_node)
          lines_between_defs(first_def_node, second_def_node).count(&:blank?)
        end

        def minimum_empty_lines
          Array(cop_config['NumberOfEmptyLines']).first
        end

        def maximum_empty_lines
          Array(cop_config['NumberOfEmptyLines']).last
        end

        def prev_node(node)
          return nil unless node.sibling_index > 0

          node.parent.children[node.sibling_index - 1]
        end

        def lines_between_defs(first_def_node, second_def_node)
          line_range = def_end(first_def_node)..(def_start(second_def_node) - 2)

          processed_source.lines[line_range]
        end

        def def_start(node)
          node.loc.keyword.line
        end

        def def_end(node)
          node.loc.end.line
        end

        def autocorrect_remove_lines(newline_pos, count)
          difference = count - maximum_empty_lines
          range_to_remove = range_between(newline_pos, newline_pos + difference)
          lambda do |corrector|
            corrector.remove(range_to_remove)
          end
        end

        def autocorrect_insert_lines(newline_pos, count)
          difference = minimum_empty_lines - count
          where_to_insert = range_between(newline_pos, newline_pos + 1)
          lambda do |corrector|
            corrector.insert_after(where_to_insert, "\n" * difference)
          end
        end
      end
    end
  end
end
