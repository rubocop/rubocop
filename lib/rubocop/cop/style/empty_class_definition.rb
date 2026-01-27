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
        include Alignment
        include RangeHelp
        extend AutoCorrector

        MSG_CLASS_DEFINITION =
          'Prefer a two-line class definition over `Class.new` for classes with no body.'
        MSG_CLASS_NEW = 'Prefer `Class.new` over class definition for classes with no body.'

        # @!method class_new_assignment?(node)
        def_node_matcher :class_new_assignment?, <<~PATTERN
          (casgn _ _ (send (const _ :Class) :new ...))
        PATTERN

        def on_casgn(node)
          return unless style == :class_definition
          return unless node.expression

          class_new_node = find_class_new_node(node.expression)
          return if chained_with_any_method?(node.expression, class_new_node)
          return if variable_parent_class?(class_new_node)

          add_offense(node, message: MSG_CLASS_DEFINITION) do |corrector|
            autocorrect_class_new(corrector, node)
          end
        end

        def on_class(node)
          return unless style == :class_new
          return unless empty_class?(node)

          add_offense(node, message: MSG_CLASS_NEW) do |corrector|
            autocorrect_class_definition(corrector, node)
          end
        end

        private

        def autocorrect_class_new(corrector, node)
          indent = ' ' * node.loc.column
          class_name = node.name
          class_new_node = find_class_new_node(node.expression)
          parent_class = extract_parent_class(class_new_node)

          replacement = if parent_class
                          "class #{class_name} < #{parent_class}\n#{indent}end"
                        else
                          "class #{class_name}\n#{indent}end"
                        end

          corrector.replace(node, replacement)
        end

        def autocorrect_class_definition(corrector, node)
          source_line = processed_source.buffer.source_line(node.loc.line)
          indent = source_line[/\A */]
          class_name = node.identifier.source
          parent_class = node.parent_class&.source
          range = range_by_whole_lines(node.source_range, include_final_newline: true)

          replacement = if parent_class
                          "#{indent}#{class_name} = Class.new(#{parent_class})\n"
                        else
                          "#{indent}#{class_name} = Class.new\n"
                        end

          corrector.replace(range, replacement)
        end

        def extract_parent_class(class_new_node)
          first_arg = class_new_node.first_argument
          first_arg&.source
        end

        def variable_parent_class?(class_new_node)
          first_arg = class_new_node.first_argument
          return false unless first_arg

          !first_arg.const_type?
        end

        def find_class_new_node(node)
          return nil unless node.send_type?
          return nil unless node.receiver&.const_type?

          return node if node.receiver.const_name.to_sym == :Class && node.method?(:new)

          nil
        end

        def chained_with_any_method?(expression_node, class_new_node)
          return true unless expression_node == class_new_node

          false
        end

        def empty_class?(node)
          body = node.body
          return true unless body

          body.begin_type? && body.children.empty?
        end
      end
    end
  end
end
