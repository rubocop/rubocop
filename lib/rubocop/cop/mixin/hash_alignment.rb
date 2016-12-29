# frozen_string_literal: true

module RuboCop
  module Cop
    # Common funcitonality for checking hash alignment.
    module HashAlignment
      # Handles calculation of deltas when the enforced style is 'key'.
      class KeyAlignment
        def checkable_layout?(_node)
          true
        end

        def deltas_for_first_pair(*)
          {}
        end

        def deltas(first_pair, current_pair)
          if Util.begins_its_line?(current_pair.source_range)
            { key: first_pair.loc.column - current_pair.loc.column }
          else
            {}
          end
        end
      end

      # Common functionality for checking alignment of hash values.
      module ValueAlignment
        include HashNode

        def checkable_layout?(node)
          !any_pairs_on_the_same_line?(node) && all_have_same_separator?(node)
        end

        def deltas(first_pair, current_pair)
          key_delta = key_delta(first_pair, current_pair)
          current_separator = current_pair.loc.operator
          separator_delta = separator_delta(first_pair, current_separator,
                                            key_delta)
          value_delta = value_delta(first_pair, current_pair) -
                        key_delta - separator_delta

          { key: key_delta, separator: separator_delta, value: value_delta }
        end

        private

        def separator_delta(first_pair, current_separator, key_delta)
          if current_separator.is?(':')
            0
          else
            hash_rocket_delta(first_pair, current_separator) - key_delta
          end
        end

        def all_have_same_separator?(node)
          first_separator = node.children.first.loc.operator.source
          node.children.butfirst.all? do |pair|
            pair.loc.operator.is?(first_separator)
          end
        end
      end

      # Handles calculation of deltas when the enforced style is 'table'.
      class TableAlignment
        include ValueAlignment

        # The table style is the only one where the first key-value pair can
        # be considered to have bad alignment.
        def deltas_for_first_pair(first_pair, node)
          self.max_key_width =
            node.children.map do |pair|
              key, _value = *pair
              key.source.length
            end.max

          separator_delta = separator_delta(first_pair,
                                            first_pair.loc.operator, 0)
          {
            separator: separator_delta,
            value: value_delta(first_pair, first_pair) - separator_delta
          }
        end

        private

        attr_accessor :max_key_width

        def key_delta(first_pair, current_pair)
          first_pair.loc.column - current_pair.loc.column
        end

        def hash_rocket_delta(first_pair, current_separator)
          first_pair.loc.column + max_key_width + 1 -
            current_separator.column
        end

        def value_delta(first_pair, current_pair)
          first_key, = *first_pair
          _, current_value = *current_pair
          correct_value_column = first_key.loc.column +
                                 spaced_separator(current_pair).length +
                                 max_key_width
          correct_value_column - current_value.loc.column
        end

        def spaced_separator(node)
          node.loc.operator.is?('=>') ? ' => ' : ': '
        end
      end

      # Handles calculation of deltas when the enforced style is 'separator'.
      class SeparatorAlignment
        include ValueAlignment

        def deltas_for_first_pair(*)
          {}
        end

        private

        def key_delta(first_pair, current_pair)
          key_end_column(first_pair) - key_end_column(current_pair)
        end

        def key_end_column(pair)
          key, _value = *pair
          key.loc.column + key.source.length
        end

        def hash_rocket_delta(first_pair, current_separator)
          first_pair.loc.operator.column - current_separator.column
        end

        def value_delta(first_pair, current_pair)
          _, first_value = *first_pair
          _, current_value = *current_pair
          first_value.loc.column - current_value.loc.column
        end
      end
    end
  end
end
