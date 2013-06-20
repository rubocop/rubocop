# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # A couple of checks related to the use method visibility modifiers.
      # Modifiers should be indented as deeps are method definitions and
      # surrounded by blank lines.
      class AccessControl < Cop
        INDENT_MSG = 'Indent %s as deep as method definitions.'
        BLANK_MSG = 'Keep a blank line before and after %s.'

        PRIVATE_NODE = s(:send, nil, :private)
        PROTECTED_NODE = s(:send, nil, :protected)
        PUBLIC_NODE = s(:send, nil, :public)

        def inspect(source_buffer, source, tokens, ast, comments)
          return unless ast
          on_node([:class, :module, :sclass], ast) do |class_node|
            class_start_col = class_node.loc.expression.column

            # we'll have to walk all class children nodes
            # except other class/module nodes
            class_node.children.compact.each do |node|
              on_node(:send, node, [:class, :module, :sclass]) do |send_node|
                if modifier_node?(send_node)
                  send_start_col = send_node.loc.expression.column
                  selector = send_node.loc.selector.source

                  if send_start_col - 2 != class_start_col
                    add_offence(:convention,
                                send_node.loc.expression,
                                format(INDENT_MSG, selector))
                  end

                  send_line = send_node.loc.line

                  unless source[send_line].chomp.empty? &&
                      source[send_line - 2].chomp.empty?
                    add_offence(:convention,
                                send_node.loc.expression,
                                format(BLANK_MSG, selector))
                  end
                end
              end
            end
          end
        end

        private

        def modifier_node?(node)
          [PRIVATE_NODE, PROTECTED_NODE, PUBLIC_NODE].include?(node)
        end
      end
    end
  end
end
