# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for enforcing a specific superclass
    module EnforceSuperclass
      def self.included(base)
        base.def_node_matcher(:class_definition, <<-PATTERN)
          (class (const _ !:#{base::SUPERCLASS}) #{base::BASE_PATTERN} ...)
        PATTERN

        base.def_node_matcher(:class_new_definition, <<-PATTERN)
          [!^(casgn nil :#{base::SUPERCLASS} ...) (send (const nil :Class) :new #{base::BASE_PATTERN})]
        PATTERN
      end

      def on_class(node)
        class_definition(node) do
          add_offense(node.children[1])
        end
      end

      def on_send(node)
        class_new_definition(node) do
          add_offense(node.children.last)
        end
      end

      def autocorrect(node)
        lambda do |corrector|
          corrector.replace(node.source_range, self.class::SUPERCLASS)
        end
      end
    end
  end
end
