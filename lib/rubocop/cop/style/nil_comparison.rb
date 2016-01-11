# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for comparison of something with nil using ==.
      #
      # @example
      #
      #  # bad
      #  if x == nil
      #
      #  # good
      #  if x.nil?
      class NilComparison < Cop
        MSG = 'Prefer the use of the `nil?` predicate.'.freeze

        OPS = [:==, :===].freeze

        NIL_NODE = s(:nil)

        def on_send(node)
          _receiver, method, args = *node
          return unless OPS.include?(method)

          add_offense(node, :selector) if args == NIL_NODE
        end

        private

        def autocorrect(node)
          new_code = node.source.sub(/\s*={2,3}\s*nil/, '.nil?')
          ->(corrector) { corrector.replace(node.source_range, new_code) }
        end
      end
    end
  end
end
