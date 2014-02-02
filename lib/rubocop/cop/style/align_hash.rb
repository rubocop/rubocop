# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the keys, separators, and values of a multi-line hash
      # literal are aligned.
      class AlignHash < Cop
        # Handles calculation of deltas (deviations from correct alignment)
        # when the enforced style is 'key'.
        class KeyAlignment
          def checkable_layout(_node)
            true
          end

          def deltas_for_first_pair(*_)
            {} # The first pair is always considered correct.
          end

          def deltas(first_pair, prev_pair, current_pair)
            if current_pair.loc.line == prev_pair.loc.line
              {}
            else
              { key: first_pair.loc.column - current_pair.loc.column }
            end
          end
        end

        # Common functionality for the styles where not only keys, but also
        # values are aligned.
        class AlignmentOfValues
          def checkable_layout(node)
            !any_pairs_on_the_same_line?(node) && all_have_same_sparator?(node)
          end

          def deltas(first_pair, prev_pair, current_pair)
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
              0 # Colon follows directly after key
            else
              hash_rocket_delta(first_pair, current_separator) - key_delta
            end
          end

          def any_pairs_on_the_same_line?(node)
            lines_of_the_children = node.children.map do |pair|
              key, _value = *pair
              key.loc.line
            end
            lines_of_the_children.uniq.size < lines_of_the_children.size
          end

          def all_have_same_sparator?(node)
            first_separator = node.children.first.loc.operator.source
            node.children[1..-1].all? do |pair|
              pair.loc.operator.is?(first_separator)
            end
          end
        end

        # Handles calculation of deltas when the enforced style is 'table'.
        class TableAlignment < AlignmentOfValues
          # The table style is the only one where the first key-value pair can
          # be considered to have bad alignment.
          def deltas_for_first_pair(first_pair, node)
            key_widths = node.children.map do |pair|
              key, _value = *pair
              key.loc.expression.source.length
            end
            @max_key_width = key_widths.max

            separator_delta = separator_delta(first_pair,
                                              first_pair.loc.operator, 0)
            {
              separator: separator_delta,
              value:     value_delta(first_pair, first_pair) - separator_delta
            }
          end

          private

          def key_delta(first_pair, current_pair)
            first_pair.loc.column - current_pair.loc.column
          end

          def hash_rocket_delta(first_pair, current_separator)
            first_pair.loc.column + @max_key_width + 1 -
              current_separator.column
          end

          def value_delta(first_pair, current_pair)
            first_key, _ = *first_pair
            _, current_value = *current_pair
            correct_value_column = first_key.loc.column +
              spaced_separator(current_pair).length + @max_key_width
            correct_value_column - current_value.loc.column
          end

          def spaced_separator(node)
            node.loc.operator.is?('=>') ? ' => ' : ': '
          end
        end

        # Handles calculation of deltas when the enforced style is 'separator'.
        class SeparatorAlignment < AlignmentOfValues
          def deltas_for_first_pair(first_pair, node)
            {} # The first pair is always considered correct.
          end

          private

          def key_delta(first_pair, current_pair)
            key_end_column(first_pair) - key_end_column(current_pair)
          end

          def key_end_column(pair)
            key, _value = *pair
            key.loc.column + key.loc.expression.source.length
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

        MSG = 'Align the elements of a hash literal if they span more than ' \
              'one line.'

        def on_hash(node)
          return if node.children.empty?
          return unless multiline?(node)

          @alignment_for_hash_rockets ||=
            new_alignment('EnforcedHashRocketStyle')
          @alignment_for_colons ||= new_alignment('EnforcedColonStyle')

          first_pair = node.children.first

          unless @alignment_for_hash_rockets.checkable_layout(node) &&
              @alignment_for_colons.checkable_layout(node)
            return
          end

          @column_deltas = alignment_for(first_pair)
            .deltas_for_first_pair(first_pair, node)
          add_offence(first_pair, :expression) unless good_alignment?

          node.children.each_cons(2) do |prev, current|
            @column_deltas = alignment_for(current).deltas(first_pair, prev,
                                                           current)
            add_offence(current, :expression) unless good_alignment?
          end
        end

        private

        def multiline?(node)
          node.loc.expression.source.include?("\n")
        end

        def alignment_for(pair)
          if pair.loc.operator.is?('=>')
            @alignment_for_hash_rockets
          else
            @alignment_for_colons
          end
        end

        def autocorrect(node)
          # We can't use the instance variable inside the lambda. That would
          # just give each lambda the same reference and they would all get the
          # last value of each. Some local variables fix the problem.
          key_delta       = @column_deltas[:key] || 0
          separator_delta = @column_deltas[:separator] || 0
          value_delta     = @column_deltas[:value] || 0

          key, value = *node

          @corrections << lambda do |corrector|
            adjust(corrector, key_delta, key.loc.expression)
            adjust(corrector, separator_delta, node.loc.operator)
            adjust(corrector, value_delta, value.loc.expression)
          end
        end

        def new_alignment(key)
          case cop_config[key]
          when 'key'       then KeyAlignment.new
          when 'table'     then TableAlignment.new
          when 'separator' then SeparatorAlignment.new
          else fail "Unknown #{key}: #{cop_config[key]}"
          end
        end

        def adjust(corrector, delta, range)
          if delta > 0
            corrector.insert_before(range, ' ' * delta)
          elsif delta < 0
            range = Parser::Source::Range.new(range.source_buffer,
                                              range.begin_pos - delta.abs,
                                              range.begin_pos)
            corrector.remove(range)
          end
        end

        def good_alignment?
          @column_deltas.values.compact.none? { |v| v != 0 }
        end
      end
    end
  end
end
