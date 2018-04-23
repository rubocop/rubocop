# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of `method_missing` without
      # falling back on `super`.
      #
      # @example
      #   #bad
      #   def method_missing(name, *args)
      #     # ...
      #   end
      #
      #   #good
      #
      #   def method_missing(name, *args)
      #     # ...
      #     super
      #   end
      class MethodMissingSuper < Cop
        MSG = 'When using `method_missing`, fall back on `super`.'.freeze

        def on_def(node)
          return unless node.method?(:method_missing)
          return if node.descendants.any?(&:zsuper_type?)

          add_offense(node)
        end
        alias on_defs on_def
      end
    end
  end
end
