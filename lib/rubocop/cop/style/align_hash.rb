# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Here we check if the keys, separators, and values of a multi-line hash
      # literal are aligned.
      class AlignHash < Cop
        include IgnoredNode

        # Handles calculation of deltas (deviations from correct alignment)
        # when the enforced style is 'key'.
        class KeyAlignment
          def checkable_layout(_node)
            true
          end

          def deltas_for_first_pair(*)
            {} # The first pair is always considered correct.
          end

          def deltas(first_pair, current_pair)
            if Util.begins_its_line?(current_pair.source_range)
              { key: first_pair.loc.column - current_pair.loc.column }
            else
              {}
            end
          end
        end

        # Common functionality for the styles where not only keys, but also
        # values are aligned.
        class AlignmentOfValues
          include HashNode # any_pairs_on_the_same_line?

          def checkable_layout(node)
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
              0 # Colon follows directly after key
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
        class TableAlignment < AlignmentOfValues
          # The table style is the only one where the first key-value pair can
          # be considered to have bad alignment.
          def deltas_for_first_pair(first_pair, node)
            key_widths = node.children.map do |pair|
              key, _value = *pair
              key.source.length
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
            first_key, = *first_pair
            _, current_value = *current_pair
            correct_value_column = first_key.loc.column +
                                   spaced_separator(current_pair).length +
                                   @max_key_width
            correct_value_column - current_value.loc.column
          end

          def spaced_separator(node)
            node.loc.operator.is?('=>') ? ' => ' : ': '
          end
        end

        # Handles calculation of deltas when the enforced style is 'separator'.
        class SeparatorAlignment < AlignmentOfValues
          def deltas_for_first_pair(*)
            {} # The first pair is always considered correct.
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

        MSG = 'Align the elements of a hash literal if they span more than ' \
              'one line.'

        def on_send(node)
          return unless (last_child = node.children.last) &&
                        hash?(last_child) &&
                        ignore_last_argument_hash?(last_child)

          ignore_node(last_child)
        end

        def on_hash(node)
          return if ignored_node?(node)
          return if node.children.empty?
          return unless node.multiline?

          @alignment_for_hash_rockets ||=
            new_alignment('EnforcedHashRocketStyle')
          @alignment_for_colons ||= new_alignment('EnforcedColonStyle')

          unless @alignment_for_hash_rockets.checkable_layout(node) &&
                 @alignment_for_colons.checkable_layout(node)
            return
          end

          check_pairs(node)
        end

        private

        def check_pairs(node)
          first_pair = node.children.first
          @column_deltas = alignment_for(first_pair)
                           .deltas_for_first_pair(first_pair, node)
          add_offense(first_pair, :expression) unless good_alignment?

          node.children.each do |current|
            @column_deltas = alignment_for(current).deltas(first_pair, current)
            add_offense(current, :expression) unless good_alignment?
          end
        end

        def ignore_last_argument_hash?(node)
          case cop_config['EnforcedLastArgumentHashStyle']
          when 'always_inspect'  then false
          when 'always_ignore'   then true
          when 'ignore_explicit' then explicit_hash?(node)
          when 'ignore_implicit' then !explicit_hash?(node)
          end
        end

        def hash?(node)
          node.respond_to?(:type) && node.type == :hash
        end

        def explicit_hash?(node)
          node.loc.begin
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

          lambda do |corrector|
            if value.nil?
              adjust(corrector, key_delta, node.source_range)
            else
              adjust(corrector, key_delta, key.source_range)
              adjust(corrector, separator_delta, node.loc.operator)
              adjust(corrector, value_delta, value.source_range)
            end
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
