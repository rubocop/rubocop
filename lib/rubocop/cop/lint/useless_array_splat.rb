# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for unncessary array splats.
      #
      # @example
      #
      # # bad:
      #
      # a, b = *[1, 2, 3]
      #
      # # good:
      #
      # a, b = [1, 2, 3]
      #
      # # bad:
      #
      # a = *[1, 2, 3]
      #
      # # good:
      #
      # a = [1, 2, 3]
      class UselessArraySplat < Cop
        MSG = 'Unnecessary array splat.'.freeze
        ARRAY_NEW_PATTERN = '(send (const nil :Array) :new ...)'.freeze

        %w(m lv cv iv c gv).each do |var_type|
          define_method("on_#{var_type}asgn") do |node|
            *, rhs = *node

            return unless rhs.is_a?(Node) && rhs.array_type?

            add_offense(rhs, splat_source_range(rhs)) if array_splat?(rhs)
          end
        end

        private

        def_node_matcher :array_splat?, <<-PATTERN
          (array (splat {(array ...) (block #{ARRAY_NEW_PATTERN} ...) #{ARRAY_NEW_PATTERN}} ...))
        PATTERN

        def splat_source_range(node)
          node.loc.expression.begin.resize(1)
        end

        def autocorrect(node)
          ->(corrector) { corrector.remove(splat_source_range(node)) }
        end
      end
    end
  end
end
