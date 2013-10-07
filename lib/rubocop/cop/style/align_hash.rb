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
            if first_pair && value_delta(nil, first_pair, @max_key_width) != 0
              @column_deltas = {}
              convention(first_pair, :expression)
            end
          end

          node.children.each_cons(2) do |prev, current|
            @column_deltas = deltas(first_pair, prev, current, @max_key_width)
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
          max_key_width = @max_key_width
          key_delta = @column_deltas[:key] || 0

          key, value = *node

          @corrections << lambda do |corrector|
            expr = node.loc.expression
            b = expr.begin_pos
            b -= key_delta.abs if key_delta < 0
            range = Parser::Source::Range.new(expr.source_buffer, b,
                                              expr.end_pos)
            source = ' ' * [key_delta, 0].max +
              if enforced_style(node) == 'key'
                expr.source
              else
                key_source = key.loc.expression.source
                padded_separator = case enforced_style(node)
                                   when 'separator'
                                     spaced_separator(node)
                                   when 'table'
                                     space = ' ' * (max_key_width -
                                                    key_source.length)
                                     if node.loc.operator.is?('=>')
                                       space + spaced_separator(node)
                                     else
                                       spaced_separator(node) + space
                                     end
                                   end
                key_source + padded_separator + value.loc.expression.source
              end
            corrector.replace(range, source)
          end
        end

        private

        def good_alignment?
          @column_deltas.values.compact.none? { |v| v != 0 }
        end

        def deltas(first_pair, prev_pair, current_pair, max_key_width)
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
            {
              key: if enforced_style == 'table'
                     key_left_alignment_delta
                   else
                     key_end_column(first_pair) - key_end_column(current_pair)
                   end,
              separator: if current_pair.loc.operator.is?(':') &&
                             enforced_style == 'table'
                           # Colon follows directly after key
                           (key_end_column(current_pair) -
                            current_pair.loc.operator.column)
                         else
                           # Aligned separator
                           (first_pair.loc.operator.column -
                            current_pair.loc.operator.column)
                         end,
              value: value_delta(first_pair, current_pair, max_key_width)
            }
          end
        end

        def key_end_column(pair)
          key, _value = *pair
          key.loc.column + key.loc.expression.source.length
        end

        def value_delta(first_pair, current_pair, max_key_width)
          key, value = *current_pair
          correct_value_column = if enforced_style(current_pair) == 'table'
                                   key.loc.column +
                                     spaced_separator(current_pair).length +
                                     max_key_width
                                 elsif first_pair.nil? # Only one pair?
                                   value.loc.column
                                 else
                                   _key1, value1 = *first_pair
                                   value1.loc.column
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
