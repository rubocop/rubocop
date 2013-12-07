# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Access modifiers should be surrounded by blank lines.
      class EmptyLinesAroundAccessModifier < Cop
        MSG = 'Keep a blank line before and after %s.'

        PRIVATE_NODE = s(:send, nil, :private)
        PROTECTED_NODE = s(:send, nil, :protected)
        PUBLIC_NODE = s(:send, nil, :public)

        def on_send(node)
          return unless modifier_node?(node)

          return if empty_lines_around?(node)

          add_offence(node, :expression)
        end

        private

        def empty_lines_around?(node)
          send_line = node.loc.line
          previous_line = processed_source[send_line - 2]
          next_line = processed_source[send_line]

          (class_def?(previous_line.lstrip) ||
           previous_line.blank?) &&
            next_line.blank?
        end

        def class_def?(line)
          %w(class module).any? { |keyword| line.start_with?(keyword) }
        end

        def message(node)
          format(MSG, node.loc.selector.source)
        end

        def modifier_node?(node)
          [PRIVATE_NODE, PROTECTED_NODE, PUBLIC_NODE].include?(node)
        end
      end
    end
  end
end
