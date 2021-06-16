# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for grouping of accessors in `class` and `module` bodies.
      # By default it enforces accessors to be placed in grouped declarations,
      # but it can be configured to enforce separating them in multiple declarations.
      #
      # NOTE: `Sorbet` is not compatible with "grouped" style. Consider "separated" style
      # or disabling this cop.
      #
      # @example EnforcedStyle: grouped (default)
      #   # bad
      #   class Foo
      #     attr_reader :bar
      #     attr_reader :baz
      #   end
      #
      #   # good
      #   class Foo
      #     attr_reader :bar, :baz
      #   end
      #
      # @example EnforcedStyle: separated
      #   # bad
      #   class Foo
      #     attr_reader :bar, :baz
      #   end
      #
      #   # good
      #   class Foo
      #     attr_reader :bar
      #     attr_reader :baz
      #   end
      #
      class AccessorGrouping < Base
        include ConfigurableEnforcedStyle
        include RangeHelp
        include VisibilityHelp
        extend AutoCorrector

        GROUPED_MSG = 'Group together all `%<accessor>s` attributes.'
        SEPARATED_MSG = 'Use one attribute per `%<accessor>s`.'

        ACCESSOR_METHODS = %i[attr_reader attr_writer attr_accessor attr].freeze

        def on_class(node)
          class_send_elements(node).each do |macro|
            next unless accessor?(macro)

            check(macro)
          end
        end
        alias on_sclass on_class
        alias on_module on_class

        private

        def check(send_node)
          return if previous_line_comment?(send_node)
          return unless grouped_style? && sibling_accessors(send_node).size > 1 ||
                        separated_style? && send_node.arguments.size > 1

          message = message(send_node)
          add_offense(send_node, message: message) do |corrector|
            autocorrect(corrector, send_node)
          end
        end

        def autocorrect(corrector, node)
          if (preferred_accessors = preferred_accessors(node))
            corrector.replace(node, preferred_accessors)
          else
            range = range_with_surrounding_space(range: node.loc.expression, side: :left)
            corrector.remove(range)
          end
        end

        def previous_line_comment?(node)
          comment_line?(processed_source[node.first_line - 2])
        end

        def class_send_elements(class_node)
          class_def = class_node.body

          if !class_def || class_def.def_type?
            []
          elsif class_def.send_type?
            [class_def]
          else
            class_def.each_child_node(:send).to_a
          end
        end

        def accessor?(send_node)
          send_node.macro? && ACCESSOR_METHODS.include?(send_node.method_name)
        end

        def grouped_style?
          style == :grouped
        end

        def separated_style?
          style == :separated
        end

        def sibling_accessors(send_node)
          send_node.parent.each_child_node(:send).select do |sibling|
            accessor?(sibling) &&
              sibling.method?(send_node.method_name) &&
              node_visibility(sibling) == node_visibility(send_node) &&
              !previous_line_comment?(sibling)
          end
        end

        def message(send_node)
          msg = grouped_style? ? GROUPED_MSG : SEPARATED_MSG
          format(msg, accessor: send_node.method_name)
        end

        def preferred_accessors(node)
          if grouped_style?
            accessors = sibling_accessors(node)
            group_accessors(node, accessors) if node == accessors.first
          else
            separate_accessors(node)
          end
        end

        def group_accessors(node, accessors)
          accessor_names = accessors.flat_map { |accessor| accessor.arguments.map(&:source) }

          "#{node.method_name} #{accessor_names.join(', ')}"
        end

        def separate_accessors(node)
          node.arguments.map do |arg|
            if arg == node.arguments.first
              "#{node.method_name} #{arg.source}"
            else
              indent = ' ' * node.loc.column
              "#{indent}#{node.method_name} #{arg.source}"
            end
          end.join("\n")
        end
      end
    end
  end
end
