# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of
      #
      # @example
      #   # bad
      #   [1, 2, 3, 4].map { |e| [e, e] }.flatten(1)
      #   [1, 2, 3, 4].collect { |e| [e, e] }.flatten(1)
      #
      #   # good
      #   [1, 2, 3, 4].flat_map { |e| [e, e] }
      #   [1, 2, 3, 4].map { |e| [e, e] }.flatten
      #   [1, 2, 3, 4].collect { |e| [e, e] }.flatten
      class FlatMap < Cop
        MSG = 'Use `flat_map` instead of `%<method>s...%<flatten>s`.'.freeze
        FLATTEN_MULTIPLE_LEVELS = ' Beware, `flat_map` only flattens 1 level ' \
                                  'and `flatten` can be used to flatten ' \
                                  'multiple levels.'.freeze

        def_node_matcher :flat_map_candidate?, <<-PATTERN
          (send (block $(send _ ${:collect :map}) ...) ${:flatten :flatten!} $...)
        PATTERN

        def on_send(node)
          flat_map_candidate?(node) do |map_node, first_method, flatten, params|
            flatten_level, = *params.first
            if cop_config['EnabledForFlattenWithoutParams'] && !flatten_level
              offense_for_levels(node, map_node, first_method, flatten)
            elsif flatten_level == 1
              offense_for_method(node, map_node, first_method, flatten)
            end
          end
        end

        def autocorrect(node)
          map_node, _first_method, _flatten, params = flat_map_candidate?(node)
          flatten_level, = *params.first

          return unless flatten_level

          range = range_between(node.loc.dot.begin_pos,
                                node.source_range.end_pos)

          lambda do |corrector|
            corrector.remove(range)
            corrector.replace(map_node.loc.selector, 'flat_map')
          end
        end

        private

        def offense_for_levels(node, map_node, first_method, flatten)
          message = MSG + FLATTEN_MULTIPLE_LEVELS
          register_offense(node, map_node, first_method, flatten, message)
        end

        def offense_for_method(node, map_node, first_method, flatten)
          register_offense(node, map_node, first_method, flatten, MSG)
        end

        def register_offense(node, map_node, first_method, flatten, message)
          range = range_between(map_node.loc.selector.begin_pos,
                                node.loc.expression.end_pos)

          add_offense(node,
                      location: range,
                      message: format(message, method: first_method,
                                               flatten: flatten))
        end
      end
    end
  end
end
