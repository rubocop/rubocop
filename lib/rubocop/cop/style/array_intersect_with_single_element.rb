# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Use `include?(element)` instead of `intersect?([element])` and
      # `intersection([element]).any?`.
      #
      # @safety
      #   The receiver might not be an array.
      #
      # @example
      #   # bad
      #   array.intersect?([element])
      #   array.intersection([element]).any?
      #
      #   # good
      #   array.include?(element)
      class ArrayIntersectWithSingleElement < Base
        extend AutoCorrector

        MSG = 'Use `include?(element)` instead of `%<method>s`.'

        RESTRICT_ON_SEND = %i[intersection intersect?].freeze

        # @!method single_element(node)
        def_node_matcher :single_element, <<~PATTERN
          (send _ _ $(array $_))
        PATTERN

        # @!method single_element_intersection(node)
        def_node_matcher :single_element_intersection, <<~PATTERN
          (send (send _ :intersection $(array $_)) :any?)
        PATTERN

        def on_send(node)
          if node.method?(:intersection)
            on_send_intersection(node)
          elsif node.method?(:intersect?)
            on_send_intersect(node)
          end
        end
        alias on_csend on_send

        private

        def on_send_intersect(node)
          array, element = single_element(node)
          return unless array

          return if variable_number_of_elements?(element)

          add_offense(
            intersect_range(node),
            message: offense_message('intersect?([element])')
          ) do |corrector|
            corrector.replace(node.loc.selector, 'include?')
            corrector.replace(array, single_element_source(array, element))
          end
        end

        def on_send_intersection(node)
          array, element = single_element_intersection(node.parent)
          return unless array

          return if variable_number_of_elements?(element)

          range = intersection_range(node)

          add_offense(
            range,
            message: offense_message('intersection([element]).any?')
          ) do |corrector|
            corrector.replace(range, "include?(#{single_element_source(array, element)})")
          end
        end

        # `[*foo]` is not a single element: the splat can expand to any number of
        # elements, so `intersect?([*foo])` is not equivalent to `include?(*foo)`.
        def variable_number_of_elements?(element)
          element.splat_type?
        end

        def single_element_source(array, element)
          array.percent_literal? ? element.value.inspect : element.source
        end

        def offense_message(method)
          format(MSG, method: method)
        end

        def intersect_range(node)
          node.source_range.with(begin_pos: node.loc.selector.begin_pos)
        end

        def intersection_range(node)
          node.source_range.with(
            begin_pos: node.loc.selector.begin_pos,
            end_pos: node.parent.source_range.end_pos
          )
        end
      end
    end
  end
end
