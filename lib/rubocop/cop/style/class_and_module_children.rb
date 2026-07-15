# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks that namespaced classes and modules are defined with a consistent style.
      #
      # With `nested` style, classes and modules should be defined separately (one constant
      # on each line, without `::`). With `compact` style, classes and modules should be
      # defined with fully qualified names (using `::` for namespaces).
      #
      # NOTE: The style chosen will affect `Module.nesting` for the class or module. Using
      # `nested` style will result in each level being added, whereas `compact` style will
      # only include the fully qualified class or module name.
      #
      # By default, `EnforcedStyle` applies to both classes and modules. If desired, separate
      # styles can be defined for classes and modules by using `EnforcedStyleForClasses` and
      # `EnforcedStyleForModules` respectively. If not set, or set to nil, the `EnforcedStyle`
      # value will be used.
      #
      # @safety
      #   Autocorrection is unsafe.
      #
      #   Moving from `compact` to `nested` children requires knowledge of whether the
      #   outer parent is a module or a class. Moving from `nested` to `compact` requires
      #   verification that the outer parent is defined elsewhere. By default RuboCop does
      #   not have the knowledge to perform either operation safely and thus requires
      #   manual oversight.
      #
      #   When `AllCops/UseProjectIndex` is enabled and the `rubydex` gem is installed,
      #   the project-wide index is consulted to resolve whether the outer parent is a
      #   class or a module, and compacting is skipped when the outer parent is not
      #   defined elsewhere.
      #
      # @example EnforcedStyle: nested (default)
      #   # bad
      #   class Foo::Bar
      #   end
      #
      #   # good
      #   class Foo
      #     class Bar
      #     end
      #   end
      #
      # @example EnforcedStyle: compact
      #   # bad
      #   class Foo
      #     class Bar
      #     end
      #   end
      #
      #   # good
      #   class Foo::Bar
      #   end
      #
      # The compact style is only forced for classes/modules with one child.
      class ClassAndModuleChildren < Base
        include Alignment
        include ConfigurableEnforcedStyle
        include ProjectIndexHelp
        include RangeHelp
        extend AutoCorrector

        NESTED_MSG = 'Use nested module/class definitions instead of compact style.'
        COMPACT_MSG = 'Use compact module/class definition instead of nested style.'

        def on_class(node)
          return if node.parent_class && style_for_classes != :nested

          check_style(node, node.body, style_for_classes)
        end

        def on_module(node)
          check_style(node, node.body, style_for_modules)
        end

        private

        def nest_or_compact(corrector, node)
          style = style_for_kind(node.type)

          if style == :nested
            nest_definition(corrector, node)
          else
            compact_definition(corrector, node)
          end
        end

        def nest_definition(corrector, node)
          keyword = namespace_keyword(node)
          # A namespace wrapper whose style resolves to `compact` would itself violate
          # that style, making autocorrection ping-pong between the two forms.
          return if style_for_kind(keyword.to_sym) == :compact

          padding = indentation(node) + leading_spaces(node)
          padding_for_trailing_end = padding.sub(' ' * node.loc.end.column, '')

          corrector.replace(node.loc.keyword, keyword)
          split_on_double_colon(corrector, node, padding)
          add_trailing_end(corrector, node, padding_for_trailing_end)
        end

        def namespace_keyword(node)
          indexed_namespace_keyword(node) || heuristic_namespace_keyword(node)
        end

        def indexed_namespace_keyword(node)
          return nil unless project_index

          declaration = resolve_in_index(node.identifier.namespace.const_name, node)

          case declaration
          when Rubydex::Class then 'class'
          when Rubydex::Module then 'module'
          end
        end

        def heuristic_namespace_keyword(node)
          class_definition = node.left_sibling&.each_node(:class)&.find do |class_node|
            class_node.identifier == node.identifier.namespace
          end

          class_definition ? 'class' : 'module'
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
          # Compacting produces a definition whose type's style resolves to `nested`,
          # making autocorrection ping-pong between the two forms.
          return if style_for_kind(node.body.type) == :nested
          return unless compactible_namespace?(node)

          compact_node(corrector, node)
          remove_end(corrector, node.body)
          unindent(corrector, node)
        end

        # Compacting removes this definition of the namespace, so the result raises
        # `NameError` at load time unless the namespace is also defined somewhere else.
        # With the project index this is verified before correcting; without it the
        # correction is performed regardless (the cop's autocorrection is unsafe).
        def compactible_namespace?(node)
          return true unless project_index

          declaration = resolve_in_index(node.identifier.const_name, node)
          return false unless declaration.is_a?(Rubydex::Namespace)

          declaration.definitions.any? { |definition| definition_elsewhere?(definition, node) }
        end

        def definition_elsewhere?(definition, node)
          location = definition.location
          return true unless location.uri.start_with?(FILE_URI_PREFIX)

          !same_file?(location.to_file_path, processed_source.file_path) ||
            location.to_display.start_line != node.first_line
        rescue StandardError
          # A path that cannot be converted or compared cannot prove the
          # namespace is defined elsewhere; err on not correcting.
          false
        end

        def same_file?(path, other)
          return true if File.identical?(path, other)

          normalized = [path, other].map { |p| File.expand_path(p).tr('\\', '/') }
          normalized.uniq.one? || (Platform.windows? && normalized[0].casecmp?(normalized[1]))
        end

        def resolve_in_index(const_name, node)
          project_index.resolve_constant(const_name, lexical_nesting(node))
        end

        def lexical_nesting(node)
          node.each_ancestor(:class, :module).map { |ancestor| ancestor.identifier.const_name }
                                             .reverse
        end

        def compact_node(corrector, node)
          range = range_between(node.loc.keyword.begin_pos, node.body.loc.name.end_pos)
          corrector.replace(range, compact_replacement(node))
        end

        def compact_replacement(node)
          replacement = "#{node.body.type} #{compact_identifier_name(node)}"

          body_comments = processed_source.ast_with_comments[node.body]
          unless body_comments.empty?
            replacement = body_comments.map(&:text).push(replacement).join("\n")
          end
          replacement
        end

        def compact_identifier_name(node)
          "#{node.identifier.const_name}::" \
            "#{node.body.children.first.const_name}"
        end

        # rubocop:disable Metrics/AbcSize
        def remove_end(corrector, body)
          remove_begin_pos = if same_line?(body.loc.name, body.loc.end)
                               body.loc.name.end_pos
                             else
                               body.loc.end.begin_pos - leading_spaces(body).size
                             end
          adjustment = processed_source.raw_source[remove_begin_pos] == ';' ? 0 : 1
          range = range_between(remove_begin_pos, body.loc.end.end_pos + adjustment)

          corrector.remove(range)
        end
        # rubocop:enable Metrics/AbcSize

        def unindent(corrector, node)
          return unless node.body.children.last

          last_child_leading_spaces = leading_spaces(node.body.children.last)
          return if spaces_size(leading_spaces(node)) == spaces_size(last_child_leading_spaces)

          column_delta = configured_indentation_width - spaces_size(last_child_leading_spaces)
          return if column_delta.zero?

          AlignmentCorrector.correct(
            corrector, processed_source, node, column_delta, tab_indentation: true
          )
        end

        def leading_spaces(node)
          node.source_range.source_line[/\A\s*/]
        end

        # A tab counts as `configured_indentation_width` columns, matching the
        # width `AlignmentCorrector` uses to convert `column_delta` back into
        # tabs. Using `Layout/IndentationStyle`'s own `IndentationWidth` here
        # would make the delta and the correction disagree.
        def spaces_size(spaces_string)
          mapping = { "\t" => configured_indentation_width }
          spaces_string.chars.sum { |character| mapping.fetch(character, 1) }
        end

        def check_style(node, body, style)
          return if node.identifier.namespace&.cbase_type?
          return unless const_namespace?(node.identifier.namespace)

          if style == :nested
            check_nested_style(node)
          else
            check_compact_style(node, body)
          end
        end

        def const_namespace?(node)
          return true if node.nil? || node.cbase_type?
          return false unless node.const_type?

          const_namespace?(node.namespace)
        end

        def check_nested_style(node)
          return unless compact_node_name?(node)
          return if node.parent&.type?(:class, :module)

          add_offense(node.loc.name, message: NESTED_MSG) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def check_compact_style(node, body)
          parent = node.parent
          return if parent&.type?(:class, :module)

          return unless needs_compacting?(body)

          add_offense(node.loc.name, message: COMPACT_MSG) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def autocorrect(corrector, node)
          return if node.class_type? && node.parent_class && style_for_classes != :nested

          nest_or_compact(corrector, node)
        end

        def needs_compacting?(body)
          body && %i[module class].include?(body.type)
        end

        def compact_node_name?(node)
          node.identifier.source.include?('::')
        end

        def style_for_kind(kind)
          kind == :class ? style_for_classes : style_for_modules
        end

        def style_for_classes
          cop_config['EnforcedStyleForClasses']&.to_sym || style
        end

        def style_for_modules
          cop_config['EnforcedStyleForModules']&.to_sym || style
        end
      end
    end
  end
end
