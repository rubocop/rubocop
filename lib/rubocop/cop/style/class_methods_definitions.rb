# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces using `def self.method_name` or `class << self` to define class methods.
      #
      # @example EnforcedStyle: def_self (default)
      #   # bad
      #   class SomeClass
      #     class << self
      #       attr_accessor :class_accessor
      #
      #       def class_method
      #         # ...
      #       end
      #     end
      #   end
      #
      #   # good
      #   class SomeClass
      #     def self.class_method
      #       # ...
      #     end
      #
      #     class << self
      #       attr_accessor :class_accessor
      #     end
      #   end
      #
      #   # good - contains private method
      #   class SomeClass
      #     class << self
      #       attr_accessor :class_accessor
      #
      #       private
      #
      #       def private_class_method
      #         # ...
      #       end
      #     end
      #   end
      #
      # @example EnforcedStyle: self_class
      #   # bad
      #   class SomeClass
      #     def self.class_method
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class SomeClass
      #     class << self
      #       def class_method
      #         # ...
      #       end
      #     end
      #   end
      #
      class ClassMethodsDefinitions < Base
        include ConfigurableEnforcedStyle
        include CommentsHelp
        include VisibilityHelp
        extend AutoCorrector

        MSG = 'Use `%<preferred>s` to define class method.'

        def on_sclass(node)
          return unless def_self_style?
          return unless node.identifier.source == 'self'
          return if contains_non_public_methods?(node)

          def_nodes(node).each do |def_node|
            next unless node_visibility(def_node) == :public

            message = format(MSG, preferred: "def self.#{def_node.method_name}")
            add_offense(def_node, message: message) do |corrector|
              extract_def_from_sclass(def_node, node, corrector)
            end
          end
        end

        def on_defs(node)
          return if def_self_style?

          message = format(MSG, preferred: 'class << self')
          add_offense(node, message: message)
        end

        private

        def def_self_style?
          style == :def_self
        end

        def contains_non_public_methods?(sclass_node)
          def_nodes(sclass_node).any? { |def_node| node_visibility(def_node) != :public }
        end

        def def_nodes(sclass_node)
          sclass_def = sclass_node.body
          return [] unless sclass_def

          if sclass_def.def_type?
            [sclass_def]
          elsif sclass_def.begin_type?
            sclass_def.each_child_node(:def).to_a
          else
            []
          end
        end

        def extract_def_from_sclass(def_node, sclass_node, corrector)
          range = source_range_with_comment(def_node)
          source = range.source.sub!(
            "def #{def_node.method_name}",
            "def self.#{def_node.method_name}"
          )

          corrector.insert_before(sclass_node, "#{source}\n#{indent(sclass_node)}")
          corrector.remove(range)
        end

        def indent(node)
          ' ' * node.loc.column
        end
      end
    end
  end
end
