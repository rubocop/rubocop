# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # A couple of checks related to the use method visibility modifiers.
      # Modifiers should be indented as deeps are method definitions and
      # surrounded by blank lines.
      class AccessModifierIndentation < Cop
        MSG = '%s access modifiers like %s.'

        PRIVATE_NODE = s(:send, nil, :private)
        PROTECTED_NODE = s(:send, nil, :protected)
        PUBLIC_NODE = s(:send, nil, :public)

        def investigate(processed_source)
          ast = processed_source.ast
          return unless ast
          on_node([:class, :module, :sclass, :block], ast) do |class_node|
            if class_node.type == :block && !class_constructor?(class_node)
              next
            end

            class_start_col = class_node.loc.expression.column

            # we'll have to walk all class children nodes
            # except other class/module nodes
            class_node.children.compact.each do |node|
              on_node(:send, node, [:class, :module, :sclass]) do |send_node|
                if modifier_node?(send_node)
                  send_start_col = send_node.loc.expression.column

                  if send_start_col != class_start_col + expected_indent_offset
                    convention(send_node, :expression)
                  end
                end
              end
            end
          end
        end

        private

        def message(node)
          format(MSG,
                 cop_config['EnforcedStyle'].capitalize,
                 node.loc.selector.source)
        end

        def class_constructor?(block_node)
          send_node = block_node.children.first
          receiver_node, method_name, *_ = *send_node
          return false unless method_name == :new
          %w(Class Module).include?(Util.const_name(receiver_node))
        end

        def expected_indent_offset
          case cop_config['EnforcedStyle'].downcase
          when 'outdent' then 0
          when 'indent' then 2
          else fail 'Unknown EnforcedStyle specified'
          end
        end

        def modifier_node?(node)
          [PRIVATE_NODE, PROTECTED_NODE, PUBLIC_NODE].include?(node)
        end
      end
    end
  end
end
