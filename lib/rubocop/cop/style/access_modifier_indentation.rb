# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Modifiers should be indented as deep as method definitions, or as deep
      # as the class/module keyword, depending on configuration.
      class AccessModifierIndentation < Cop
        include AutocorrectAlignment
        include ConfigurableEnforcedStyle

        MSG = '%s access modifiers like %s.'

        PRIVATE_NODE = s(:send, nil, :private)
        PROTECTED_NODE = s(:send, nil, :protected)
        PUBLIC_NODE = s(:send, nil, :public)

        def on_class(node)
          _name, _base_class, body = *node
          check_body(body, node)
        end

        def on_sclass(node)
          _name, body = *node
          check_body(body, node)
        end

        def on_module(node)
          _name, body = *node
          check_body(body, node)
        end

        def on_block(node)
          _method, _args, body = *node
          check_body(body, node) if class_constructor?(node)
        end

        def self.modifier_node?(node)
          [PRIVATE_NODE, PROTECTED_NODE, PUBLIC_NODE].include?(node)
        end

        private

        def check_body(body, node)
          return if body.nil? # Empty class etc.

          modifiers = body.children.select { |c| self.class.modifier_node?(c) }
          class_column = node.loc.expression.column

          modifiers.each { |modifier| check_modifier(modifier, class_column) }
        end

        def check_modifier(send_node, class_start_col)
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
