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

          send_line = node.loc.line

          unless processed_source[send_line].blank? &&
              processed_source[send_line - 2].blank?
            convention(node, :expression)
          end
        end

        private

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
