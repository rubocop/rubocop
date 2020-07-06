# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for grouping of accessors in `class` and `module` bodies.
      # By default it enforces accessors to be placed in grouped declarations,
      # but it can be configured to enforce separating them in multiple declarations.
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
      class AccessorGrouping < Cop
        include ConfigurableEnforcedStyle

        GROUPED_MSG = 'Group together all `%<accessor>s` attributes.'
        SEPARATED_MSG = 'Use one attribute per `%<accessor>s`.'

        ACCESSOR_METHODS = %i[attr_reader attr_writer attr_accessor attr].freeze

        def on_class(node)
          class_send_elements(node).each do |macro|
            next unless accessor?(macro)

            check(macro)
          end
        end
        alias on_module on_class

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node, correction(node))
          end
        end

        private

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

        def check(send_node)
          if grouped_style? && sibling_accessors(send_node).size > 1
            add_offense(send_node)
          elsif separated_style? && send_node.arguments.size > 1
            add_offense(send_node)
          end
        end

        def grouped_style?
          style == :grouped
        end

        def separated_style?
          style == :separated
        end

        def sibling_accessors(send_node)
          send_node.parent.each_child_node(:send).select do |sibling|
            sibling.macro? && sibling.method?(send_node.method_name)
          end
        end

        def message(send_node)
          msg = grouped_style? ? GROUPED_MSG : SEPARATED_MSG
          format(msg, accessor: send_node.method_name)
        end

        def correction(node)
          if grouped_style?
            accessors = sibling_accessors(node)
            if node == accessors.first
              group_accessors(node, accessors)
            else
              ''
            end
          else
            separate_accessors(node)
          end
        end

        def group_accessors(node, accessors)
          accessor_names = accessors.flat_map do |accessor|
            accessor.arguments.map(&:source)
          end

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
