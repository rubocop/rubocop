# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # A couple of checks related to the use method visibility modifiers.
      # Modifiers should be indented as deeps are method definitions and
      # surrounded by blank lines.
      class AccessModifierIndentation < Cop
        include AutocorrectAlignment
        include ConfigurableEnforcedStyle

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
                if self.class.modifier_node?(send_node)
                  check(send_node, class_start_col)
                end
              end
            end
          end
        end

        def self.modifier_node?(node)
          [PRIVATE_NODE, PROTECTED_NODE, PUBLIC_NODE].include?(node)
        end

        private

        def check(send_node, class_start_col)
          access_modifier_start_col = send_node.loc.expression.column
          offset = access_modifier_start_col - class_start_col

          @column_delta = expected_indent_offset - offset
          if @column_delta == 0
            correct_style_detected
          else
            add_offence(send_node, :expression) do
              if offset == unexpected_indent_offset
                opposite_style_detected
              else
                unrecognized_style_detected
              end
            end
          end
        end

        def message(node)
          format(MSG, style.capitalize, node.loc.selector.source)
        end

        def class_constructor?(block_node)
          send_node = block_node.children.first
          receiver_node, method_name, *_ = *send_node
          return false unless method_name == :new
          %w(Class Module).include?(Util.const_name(receiver_node))
        end

        def expected_indent_offset
          style == :outdent ? 0 : IndentationWidth::CORRECT_INDENTATION
        end

        # An offset that is not expected, but correct if the configuration is
        # changed.
        def unexpected_indent_offset
          IndentationWidth::CORRECT_INDENTATION - expected_indent_offset
        end
      end
    end
  end
end
