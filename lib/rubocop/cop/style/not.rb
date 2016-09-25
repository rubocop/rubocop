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

          if opposite_method?(child)
            correct_opposite_method(range, child)
          elsif requires_parens?(child)
            correct_with_parens(range, node)
          else
            correct_without_parens(range)
          end
        end

        def opposite_method?(child)
          child.send_type? && OPPOSITE_METHODS.key?(child.method_name)
        end

        def requires_parens?(child)
          child.and_type? || child.or_type? || child.binary_operation? ||
            ternary?(child)
        end

        def correct_opposite_method(range, child)
          lambda do |corrector|
            corrector.remove(range)
            corrector.replace(child.loc.selector,
                              OPPOSITE_METHODS[child.method_name].to_s)
          end
        end

        def correct_with_parens(range, node)
          lambda do |corrector|
            corrector.replace(range, '!(')
            corrector.insert_after(node.source_range, ')')
          end
        end

        def correct_without_parens(range)
          ->(corrector) { corrector.replace(range, '!') }
        end
      end
    end
  end
end
