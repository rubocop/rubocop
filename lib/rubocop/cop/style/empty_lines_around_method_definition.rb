# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cops checks if empty lines exist around the method definitions.
      #
      # @example
      #
      #   # good
      #
      #   class Foo
      #
      #     def foo
      #       ...
      #     end
      #
      #   end
      #
      #   # bad
      #
      #   class Bar
      #     def bar
      #       ...
      #     end
      #   end
      class EmptyLinesAroundMethodDefinition < Cop
        include OnMethodDef

        MSG = 'Use empty line %s method definition.'.freeze

        def on_method_def(node, _method_name, _args, _body)
          check(node)
        end

        private

        def check(node)
          check_previous_line(node)
          check_next_line(node)
        end

        def check_previous_line(node)
          return if node.single_line? && prev_node_single_line?(node)

          previous_line = previous_line_ignoring_comments(
            processed_source,
            node.loc.expression.first_line
          )
          check_line(previous_line, format(MSG, 'before'), 1)
        end

        def check_next_line(node)
          return if node.single_line? && next_node_single_line?(node)

          next_line = node.loc.expression.last_line
          check_line(next_line, format(MSG, 'after'), -1)
        end

        def check_line(line, msg, offset)
          source = processed_source.lines[line]
          return if source && source.blank?

          range = source_range(processed_source.buffer, line + offset, 0)
          add_offense(range, range, msg)
        end

        def previous_line_ignoring_comments(processed_source, send_line)
          (send_line - 2).downto(0) do |line|
            return line unless comment_line?(processed_source[line])
          end
          0
        end

        def prev_node_single_line?(node)
          prev_node = prev_node(node)
          prev_node && prev_node.single_line?
        end

        def next_node_single_line?(node)
          next_node = next_node(node)
          next_node && next_node.single_line?
        end

        def prev_node(node)
          return nil unless node.sibling_index > 0

          node.parent.children[node.sibling_index - 1]
        end

        def next_node(node)
          return nil unless node.parent.children.count > node.sibling_index

          node.parent.children[node.sibling_index + 1]
        end
      end
    end
  end
end
