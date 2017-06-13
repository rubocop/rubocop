# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of `method_missing` without also
      # defining `respond_to_missing?` and falling back on `super`.
      #
      # @example
      #   #bad
      #   def method_missing(...)
      #     ...
      #   end
      #
      #   #good
      #   def respond_to_missing?(...)
      #     ...
      #   end
      #
      #   def method_missing(...)
      #     ...
      #     super
      #   end
      class MethodMissing < Cop
        MSG = 'When using `method_missing`, %s.'.freeze

        def on_def(node)
          return unless node.method?(:method_missing)

          check(node)
        end
        alias on_defs on_def

        private

        def check(node)
          return if calls_super?(node) && implements_respond_to_missing?(node)

          add_offense(node)
        end

        def message(node)
          instructions = []

          unless implements_respond_to_missing?(node)
            instructions << 'define `respond_to_missing?`'.freeze
          end

          unless calls_super?(node)
            instructions << 'fall back on `super`'.freeze
          end

          format(MSG, instructions.join(' and '))
        end

        def calls_super?(node)
          node.descendants.any?(&:zsuper_type?)
        end

        def implements_respond_to_missing?(node)
          node.parent.each_child_node(node.type).any? do |sibling|
            sibling.method?(:respond_to_missing?)
          end
        end
      end
    end
  end
end
