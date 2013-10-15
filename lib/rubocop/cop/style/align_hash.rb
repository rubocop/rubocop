# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Here we check if the keys, separators, and values of a multi-line hash
      # literal are aligned.
      class AlignHash < Cop
        MSG = 'Align the elements of a hash literal if they span more than ' +
          'one line.'

        def on_hash(node)
          first_pair = node.children.first

          styles = [cop_config['EnforcedHashRocketStyle'],
                    cop_config['EnforcedColonStyle']]

          if styles.include?('table') || styles.include?('separator')
            return if any_pairs_on_the_same_line?(node)
          end

          if styles.include?('table')
            key_widths = node.children.map do |pair|
              key, _value = *pair
              key.loc.expression.source.length
            end
            @max_key_width = key_widths.max
            if first_pair
              separator_delta = separator_delta(first_pair,
                                                first_pair.loc.operator, 0,
                                                enforced_style(first_pair))
              @column_deltas = {
                separator: separator_delta,
                value:     value_delta(nil, first_pair) - separator_delta
              }
              convention(first_pair, :expression) unless good_alignment?
            end
          end

          node.children.each_cons(2) do |prev, current|
            @column_deltas = deltas(first_pair, prev, current)
            convention(current, :expression) unless good_alignment?
          end
        end

        def any_pairs_on_the_same_line?(node)
          lines_of_the_children = node.children.map do |pair|
            key, _value = *pair
            key.loc.line
          end
          lines_of_the_children.uniq.size < lines_of_the_children.size
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

        private

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

        def deltas(first_pair, prev_pair, current_pair)
          enforced_style = enforced_style(current_pair)
          unless %w(key separator table).include?(enforced_style)
            fail "Unknown #{config_parameter(current_pair)}: #{enforced_style}"
          end

          return {} if current_pair.loc.line == prev_pair.loc.line

          key_left_alignment_delta = (first_pair.loc.column -
                                      current_pair.loc.column)
          if enforced_style == 'key'
            { key: key_left_alignment_delta }
          else
            key_delta = if enforced_style == 'table'
                          key_left_alignment_delta
                        else
                          (key_end_column(first_pair) -
                           key_end_column(current_pair))
                        end
            current_separator = current_pair.loc.operator
            separator_delta = separator_delta(first_pair, current_separator,
                                              key_delta, enforced_style)
            value_delta = value_delta(first_pair, current_pair) -
              key_delta - separator_delta

            { key: key_delta, separator: separator_delta, value: value_delta }
          end
        end

        def separator_delta(first_pair, current_separator, key_delta,
                            enforced_style)
          if current_separator.is?(':')
            0 # Colon follows directly after key
          elsif enforced_style == 'table'
            first_pair.loc.expression.column + @max_key_width + 1 -
              current_separator.column - key_delta
          else
            # separator
            first_pair.loc.operator.column - current_separator.column -
              key_delta
          end
        end

        def key_end_column(pair)
          key, _value = *pair
          key.loc.column + key.loc.expression.source.length
        end

        def value_delta(first_pair, current_pair)
          key, value = *current_pair
          if first_pair.nil?
            k, v = key, value
          else
            k, v = *first_pair
          end
          correct_value_column =
            if enforced_style(current_pair) == 'table'
              k.loc.column + spaced_separator(current_pair).length +
                @max_key_width
            else
              v.loc.column
            end
          correct_value_column - value.loc.column
        end

        def spaced_separator(node)
          node.loc.operator.is?('=>') ? ' => ' : ': '
        end

        def enforced_style(node)
          cop_config[config_parameter(node)]
        end

        def config_parameter(node)
          separator = node.loc.operator.is?('=>') ? 'HashRocket' : 'Colon'
          "Enforced#{separator}Style"
        end
      end
    end
  end
end
