# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks the style of children definitions at classes and
      # modules. Basically there are two different styles:
      #
      # @example EnforcedStyle: nested (default)
      #   # good
      #   # have each child on its own line
      #   class Foo
      #     class Bar
      #     end
      #   end
      #
      # @example EnforcedStyle: compact
      #   # good
      #   # combine definitions as much as possible
      #   class Foo::Bar
      #   end
      #
      # The compact style is only forced for classes/modules with one child.
      class ClassAndModuleChildren < Base
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector

        NESTED_MSG = 'Use nested module/class definitions instead of ' \
                     'compact style.'
        COMPACT_MSG = 'Use compact module/class definition instead of ' \
                      'nested style.'

        def on_class(node)
          return if node.parent_class && style != :nested

          check_style(node, node.body)
        end

        def on_module(node)
          check_style(node, node.body)
        end

        private

        def nest_or_compact(corrector, node)
          if style == :nested
            nest_definition(corrector, node)
          else
            compact_definition(corrector, node)
          end
        end

        def nest_definition(corrector, node)
          padding = ((' ' * indent_width) + leading_spaces(node)).to_s
          padding_for_trailing_end = padding.sub(' ' * node.loc.end.column, '')

          replace_namespace_keyword(corrector, node)
          split_on_double_colon(corrector, node, padding)
          add_trailing_end(corrector, node, padding_for_trailing_end)
        end

        def replace_namespace_keyword(corrector, node)
          class_definition = node.left_sibling&.each_node(:class)&.find do |class_node|
            class_node.identifier == node.identifier.namespace
          end
          namespace_keyword = class_definition ? 'class' : 'module'

          corrector.replace(node.loc.keyword, namespace_keyword)
        end

        def split_on_double_colon(corrector, node, padding)
          children_definition = node.children.first
          range = range_between(children_definition.loc.double_colon.begin_pos,
                                children_definition.loc.double_colon.end_pos)
          replacement = "\n#{padding}#{node.loc.keyword.source} "

          corrector.replace(range, replacement)
        end

        def add_trailing_end(corrector, node, padding)
          replacement = "#{padding}end\n#{leading_spaces(node)}end"
          corrector.replace(node.loc.end, replacement)
        end

        def compact_definition(corrector, node)
          compact_node(corrector, node)
          remove_end(corrector, node.body)
        end

        def compact_node(corrector, node)
          replacement = "#{node.body.type} #{compact_identifier_name(node)}"
          range = range_between(node.loc.keyword.begin_pos,
                                node.body.loc.name.end_pos)
          corrector.replace(range, replacement)
        end

        def compact_identifier_name(node)
          "#{node.identifier.const_name}::" \
            "#{node.body.children.first.const_name}"
        end

        def remove_end(corrector, body)
          range = range_between(
            body.loc.end.begin_pos - leading_spaces(body).size,
            body.loc.end.end_pos + 1
          )
          corrector.remove(range)
        end

        def leading_spaces(node)
          node.source_range.source_line[/\A\s*/]
        end

        def indent_width
          @config.for_cop('Layout/IndentationWidth')['Width'] || 2
        end

        def check_style(node, body)
          return if node.identifier.children[0]&.cbase_type?

          if style == :nested
            check_nested_style(node)
          else
            check_compact_style(node, body)
          end
        end

        def check_nested_style(node)
          return unless compact_node_name?(node)

          add_offense(node.loc.name, message: NESTED_MSG) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def check_compact_style(node, body)
          return unless one_child?(body) && !compact_node_name?(node)

          add_offense(node.loc.name, message: COMPACT_MSG) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def autocorrect(corrector, node)
          return if node.class_type? && node.parent_class && style != :nested

          nest_or_compact(corrector, node)
        end

        def one_child?(body)
          body && %i[module class].include?(body.type)
        end

        def compact_node_name?(node)
          /::/.match?(node.loc.name.source)
        end
      end
    end
  end
end
