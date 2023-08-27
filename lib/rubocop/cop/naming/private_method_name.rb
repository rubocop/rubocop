# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Checks that private methods names
      # do not start without a underscore prefix.
      #
      # @example
      #   # bad
      #   class MyClass
      #     private
      #     def foo
      #       # ...
      #     end
      #   end
      #
      #   # bad
      #   class MyClass
      #     def self.foo
      #       # ...
      #     end
      #
      #     private_class_method :foo
      #   end
      #
      #   # good
      #   class MyClass
      #     private
      #     def _foo
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class MyClass
      #     def self._foo
      #       # ...
      #     end
      #
      #     private_class_method :_foo
      #   end
      #
      class PrivateMethodName < Base
        extend AutoCorrector

        include VisibilityHelp
        include RangeHelp

        MSG = 'Use `%<preferred>s` instead of `%<bad>s`.'

        # @!method private_class_methods(node)
        def_node_search :private_class_methods, <<~PATTERN
          (send nil? :private_class_method $...)
        PATTERN

        # @!method sym_name(node)
        def_node_matcher :sym_name, '(sym $_name)'

        # @!method str_name(node)
        def_node_matcher :str_name, '(str $_name)'

        def on_send(node)
          return unless (attrs = node.attribute_accessor?)

          attrs.last.each do |name_item|
            name = attr_name(name_item)
            next unless name
            next if node_visibility(node) != :private
            next if preferred_name?(name)

            register_offense(node: node, method_name: name)
          end
        end

        def on_defs(node)
          private_class_method_names = private_class_method_names(node.parent)
          method_name = node.method_name
          return unless private_class_method_names.include?(method_name)

          return if preferred_name?(method_name)

          register_offense(node: node, method_name: method_name)
        end

        def on_def(node)
          return if node.operator_method? || node_visibility(node) != :private

          method_name = node.method_name
          return if preferred_name?(method_name)

          register_offense(node: node, method_name: method_name)
        end

        private

        def register_offense(node:, method_name:)
          range = range_position(node)
          preferred_name = "_#{method_name}"
          message = format(MSG, preferred: preferred_name, bad: method_name)

          add_offense(range, message: message)
        end

        def attr_name(name_item)
          sym_name(name_item) || str_name(name_item)
        end

        def preferred_name?(method_name)
          method_name.start_with?('_')
        end

        def range_position(node)
          method_definition = base_for_method_definition(node)
          start_pos = method_definition.end_pos + 1
          end_pos = node.source_range.end_pos

          range_between(start_pos, end_pos)
        end

        def base_for_method_definition(node)
          if node.send_type?
            node.loc.selector
          elsif node.keyword?
            node.loc.keyword
          else
            node.body.source_range
          end
        end

        def private_class_method_names(node)
          private_class_methods(node).to_a.flatten.select(&:basic_literal?).map(&:value)
        end
      end
    end
  end
end
