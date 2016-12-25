# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether method definitions are
      # separated by empty lines.
      class EmptyLineBetweenDefs < Cop
        MSG = 'Use empty lines between method definitions.'.freeze

        # We operate on `begin` nodes, instead of using `OnMethodDef`,
        # so that we can walk over pairs of consecutive nodes and
        # efficiently access a node's predecessor; #prev_node ends up
        # doing a linear scan over siblings, so we don't want to call
        # it on each def.
        def on_begin(node)
          node.children.each_cons(2) do |prev, child|
            nodes = [prev, child]
            check_defs(nodes) if nodes.all? { |n| def_node?(n) }
          end
        end

        def check_defs(nodes)
          return if blank_lines_between?(*nodes)
          return if nodes.all?(&:single_line?) &&
                    cop_config['AllowAdjacentOneLineDefs']

          add_offense(nodes.last, :keyword)
        end

        private

        def def_node?(node)
          return unless node
          node.def_type? || node.defs_type?
        end

        def blank_lines_between?(first_def_node, second_def_node)
          lines_between_defs(first_def_node, second_def_node).any?(&:blank?)
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

        def autocorrect(node)
          prev_def = prev_node(node)
          end_pos = prev_def.loc.end.end_pos
          source_buffer = prev_def.loc.end.source_buffer
          newline_pos = source_buffer.source.index("\n", end_pos)
          newline = range_between(newline_pos, newline_pos + 1)
          ->(corrector) { corrector.insert_after(newline, "\n") }
        end
      end
    end
  end
end
