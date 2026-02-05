# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces consistent style for empty class definitions.
      #
      # This cop can enforce either a two-line class definition or `Class.new`
      # for classes with no body.
      #
      # The supported styles are:
      #
      # * class_definition (default) - prefer two-line class definition over `Class.new`
      # * class_new - prefer `Class.new` over class definition
      #
      # @example EnforcedStyle: class_definition (default)
      #   # bad
      #   FooError = Class.new(StandardError)
      #
      #   # okish
      #   class FooError < StandardError; end
      #
      #   # good
      #   class FooError < StandardError
      #   end
      #
      # @example EnforcedStyle: class_new
      #   # bad
      #   class FooError < StandardError
      #   end
      #
      #   # bad
      #   class FooError < StandardError; end
      #
      #   # good
      #   FooError = Class.new(StandardError)
      #
      class EmptyClassDefinition < Base
        include ConfigurableEnforcedStyle
        include RangeHelp
        extend AutoCorrector

        MSG_CLASS_DEFINITION =
          'Prefer a two-line class definition over `Class.new` for classes with no body.'
        MSG_CLASS_NEW = 'Prefer `Class.new` over class definition for classes with no body.'

        # @!method class_new_assignment(node)
        def_node_matcher :class_new_assignment, <<~PATTERN
          (casgn _ _ $(send (const _ :Class) :new ...))
        PATTERN

        def on_casgn(node)
          return unless style == :class_definition
          return unless (class_new_node = class_new_assignment(node))
          return if (arg = class_new_node.first_argument) && !arg.const_type?

          add_offense(node, message: MSG_CLASS_DEFINITION) do |corrector|
            autocorrect_class_new(corrector, node, class_new_node)
          end
        end

        def on_class(node)
          return unless style == :class_new
          return if (body = node.body) && !body.children.empty?

          add_offense(node, message: MSG_CLASS_NEW) do |corrector|
            autocorrect_class_definition(corrector, node)
          end
        end

        private

        def autocorrect_class_new(corrector, node, class_new_node)
          indent = ' ' * node.loc.column
          class_name = node.name
          if (parent_class = class_new_node.first_argument)
            parent_class_name = " < #{parent_class.source}"
          end

          corrector.replace(node, "class #{class_name}#{parent_class_name}\n#{indent}end")
        end

        def autocorrect_class_definition(corrector, node)
          indent = ' ' * node.loc.column
          class_name = node.identifier.source
          if (parent_class = node.parent_class)
            parent_class_name = "(#{parent_class.source})"
          end
          range = range_by_whole_lines(node.source_range, include_final_newline: true)

          corrector.replace(range, "#{indent}#{class_name} = Class.new#{parent_class_name}\n")
        end
      end
    end
  end
end
