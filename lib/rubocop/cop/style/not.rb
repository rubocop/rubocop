# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses if the keyword *not* instead of !.
      class Not < Cop
        include IfNode

        MSG = 'Use `!` instead of `not`.'.freeze

        OPPOSITE_METHODS = {
          :== => :!=,
          :!= => :==,
          :<= => :>,
          :> => :<=,
          :< => :>=,
          :>= => :<
        }.freeze

        def on_send(node)
          return unless node.keyword_not?

          add_offense(node, :selector)
        end

        private

        def autocorrect(node)
          range = range_with_surrounding_space(node.loc.selector, :right)
          child = node.children.first

          if child.send_type? && OPPOSITE_METHODS.key?(child.method_name)
            lambda do |corrector|
              corrector.remove(range)
              corrector.replace(child.loc.selector,
                                OPPOSITE_METHODS[child.method_name].to_s)
            end
          elsif child.and_type? || child.or_type? || child.binary_operation? ||
                ternary?(child)
            lambda do |corrector|
              corrector.replace(range, '!(')
              corrector.insert_after(node.source_range, ')')
            end
          else
            ->(corrector) { corrector.replace(range, '!') }
          end
        end
      end
    end
  end
end
