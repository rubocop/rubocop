# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Modifiers should be indented as deep as method definitions, or as deep
      # as the class/module keyword, depending on configuration.
      #
      # @example EnforcedStyle: indent (default)
      #   # bad
      #   class Plumbus
      #   private
      #     def smooth; end
      #   end
      #
      #   # good
      #   class Plumbus
      #     private
      #     def smooth; end
      #   end
      #
      # @example EnforcedStyle: outdent
      #   # bad
      #   class Plumbus
      #     private
      #     def smooth; end
      #   end
      #
      #   # good
      #   class Plumbus
      #   private
      #     def smooth; end
      #   end
      class AccessModifierIndentation < Cop
        include AutocorrectAlignment
        include ConfigurableEnforcedStyle

        MSG = '%s access modifiers like `%s`.'.freeze

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
          return unless node.class_constructor?

          check_body(node.body, node)
        end

        private

        def check_body(body, node)
          return if body.nil? # Empty class etc.

          modifiers = body.each_child_node(:send).select(&:access_modifier?)
          class_column = node.source_range.column

          modifiers.each { |modifier| check_modifier(modifier, class_column) }
        end

        def check_modifier(send_node, class_start_col)
          access_modifier_start_col = send_node.source_range.column
          offset = access_modifier_start_col - class_start_col

          @column_delta = expected_indent_offset - offset
          if @column_delta.zero?
            correct_style_detected
          else
            add_offense(send_node) do
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

        def expected_indent_offset
          style == :outdent ? 0 : configured_indentation_width
        end

        # An offset that is not expected, but correct if the configuration is
        # changed.
        def unexpected_indent_offset
          configured_indentation_width - expected_indent_offset
        end
      end
    end
  end
end
