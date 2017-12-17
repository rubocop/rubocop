# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking hash alignment.
    module HashAlignment
      private

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
            { key: first_pair.key_delta(current_pair) }
          else
            {}
          end
        end
      end

      # Common functionality for checking alignment of hash values.
      module ValueAlignment
        def checkable_layout?(node)
          !node.pairs_on_same_line? && !node.mixed_delimiters?
        end

        def deltas(first_pair, current_pair)
          key_delta = key_delta(first_pair, current_pair)
          separator_delta = separator_delta(first_pair, current_pair,
                                            key_delta)
          value_delta = value_delta(first_pair, current_pair) -
                        key_delta - separator_delta

          { key: key_delta, separator: separator_delta, value: value_delta }
        end

        private

        def separator_delta(first_pair, current_pair, key_delta)
          if current_pair.hash_rocket?
            hash_rocket_delta(first_pair, current_pair) - key_delta
          else
            0
          end
        end
      end

      # Handles calculation of deltas when the enforced style is 'table'.
      class TableAlignment
        include ValueAlignment

        # The table style is the only one where the first key-value pair can
        # be considered to have bad alignment.
        def deltas_for_first_pair(first_pair, node)
          self.max_key_width = node.keys.map { |key| key.source.length }.max

          separator_delta = separator_delta(first_pair, first_pair, 0)
          {
            separator: separator_delta,
            value: value_delta(first_pair, first_pair) - separator_delta
          }
        end

        private

        attr_accessor :max_key_width

        def key_delta(first_pair, current_pair)
          first_pair.key_delta(current_pair)
        end

        def hash_rocket_delta(first_pair, current_pair)
          first_pair.loc.column + max_key_width + 1 -
            current_pair.loc.operator.column
        end

        def value_delta(first_pair, current_pair)
          return 0 if current_pair.kwsplat_type?

          correct_value_column = first_pair.key.loc.column +
                                 current_pair.delimiter(true).length +
                                 max_key_width
          correct_value_column - current_pair.value.loc.column
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
          first_pair.key_delta(current_pair, :right)
        end

        def hash_rocket_delta(first_pair, current_pair)
          first_pair.delimiter_delta(current_pair)
        end

        def value_delta(first_pair, current_pair)
          first_pair.value_delta(current_pair)
        end
      end
    end
  end
end
