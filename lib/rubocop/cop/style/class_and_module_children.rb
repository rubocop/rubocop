# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks the style of children definitions at classes and
      # modules. Basically there are two different styles:
      #
      # nested - have each child on its own line
      #   class Foo
      #     class Bar
      #     end
      #   end
      #
      # compact - combine definitions as much as possible
      #   class Foo::Bar
      #   end
      #
      # The compact style is only forced, for classes / modules with one child.
      class ClassAndModuleChildren < Cop
        include ConfigurableEnforcedStyle

        NESTED_MSG = 'Use nested module/class definitions instead of ' \
                     'compact style.'.freeze

        COMPACT_MSG = 'Use compact module/class definition instead of ' \
                      'nested style.'.freeze

        def on_class(node)
          _name, _superclass, body = *node
          check_style(node, body)
        end

        def on_module(node)
          _name, body = *node
          check_style(node, body)
        end

        private

        def check_style(node, body)
          if style == :nested
            check_nested_style(node)
          else
            check_compact_style(node, body)
          end
        end

        def check_nested_style(node)
          return unless compact_node_name?(node)
          add_offense(node, :name, NESTED_MSG)
        end

        def check_compact_style(node, body)
          return unless one_child?(body) && !compact_node_name?(node)
          add_offense(node, :name, COMPACT_MSG)
        end

        def one_child?(body)
          body && [:module, :class].include?(body.type)
        end

        def compact_node_name?(node)
          node.loc.name.source =~ /::/
        end
      end
    end
  end
end
