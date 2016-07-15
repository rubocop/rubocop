# encoding: utf-8
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
        include OnMethodDef

        MSG = 'When using `method_missing`, %s.'.freeze

        def on_method_def(node, method_name, _args, _body)
          return unless method_name == :method_missing

          check(node)
        end

        private

        def check(node)
          return if calls_super?(node) && implements_respond_to_missing?(node)

          add_offense(node, :expression)
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
          node.parent.children.any? do |sibling|
            respond_to_missing_def?(sibling)
          end
        end

        def_node_matcher :respond_to_missing_def?, <<-PATTERN
          (def :respond_to_missing? (...) ...)
        PATTERN
      end
    end
  end
end
