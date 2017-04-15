# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Check that the keys, separators, and values of a multi-line hash
      # literal are aligned according to configuration. The configuration
      # options are:
      #
      #   - key (left align keys)
      #   - separator (align hash rockets and colons, right align keys)
      #   - table (left align keys, hash rockets, and values)
      #
      # The treatment of hashes passed as the last argument to a method call
      # can also be configured. The options are:
      #
      #   - always_inspect
      #   - always_ignore
      #   - ignore_implicit (without curly braces)
      #   - ignore_explicit (with curly braces)
      #
      # @example
      #
      #   # EnforcedHashRocketStyle: key (default)
      #   # EnforcedColonStyle: key (default)
      #
      #   # good
      #   {
      #     foo: bar,
      #     ba: baz
      #   }
      #   {
      #     :foo => bar,
      #     :ba => baz
      #   }
      #
      #   # bad
      #   {
      #     foo: bar,
      #      ba: baz
      #   }
      #   {
      #     :foo => bar,
      #      :ba => baz
      #   }
      #
      # @example
      #
      #   # EnforcedHashRocketStyle: separator
      #   # EnforcedColonStyle: separator
      #
      #   #good
      #   {
      #     foo: bar,
      #      ba: baz
      #   }
      #   {
      #     :foo => bar,
      #      :ba => baz
      #   }
      #
      #   #bad
      #   {
      #     foo: bar,
      #     ba: baz
      #   }
      #   {
      #     :foo => bar,
      #     :ba => baz
      #   }
      #   {
      #     :foo => bar,
      #     :ba  => baz
      #   }
      #
      # @example
      #
      #   # EnforcedHashRocketStyle: table
      #   # EnforcedColonStyle: table
      #
      #   #good
      #   {
      #     foo: bar,
      #     ba:  baz
      #   }
      #   {
      #     :foo => bar,
      #     :ba  => baz
      #   }
      #
      #   #bad
      #   {
      #     foo: bar,
      #     ba: baz
      #   }
      #   {
      #     :foo => bar,
      #      :ba => baz
      #   }
      class AlignHash < Cop
        include HashAlignment

        MSG = 'Align the elements of a hash literal if they span more than ' \
              'one line.'.freeze

        def on_send(node)
          return if double_splat?(node)

          last_argument = node.last_argument

          return unless last_argument.hash_type? &&
                        ignore_hash_argument?(last_argument)

          ignore_node(last_argument)
        end

        def on_hash(node)
          return if ignored_node?(node)
          return if node.pairs.empty? || node.single_line?

          return unless alignment_for_hash_rockets.checkable_layout?(node) &&
                        alignment_for_colons.checkable_layout?(node)

          check_pairs(node)
        end

        private

        attr_accessor :column_deltas

        def double_splat?(node)
          node.children.last.is_a?(Symbol)
        end

        def check_pairs(node)
          first_pair = node.pairs.first
          self.column_deltas = alignment_for(first_pair)
                               .deltas_for_first_pair(first_pair, node)
          add_offense(first_pair, :expression) unless good_alignment?

          node.children.each do |current|
            self.column_deltas = alignment_for(current)
                                 .deltas(first_pair, current)
            add_offense(current, :expression) unless good_alignment?
          end
        end

        def ignore_hash_argument?(node)
          case cop_config['EnforcedLastArgumentHashStyle']
          when 'always_inspect'  then false
          when 'always_ignore'   then true
          when 'ignore_explicit' then node.braces?
          when 'ignore_implicit' then !node.braces?
          end
        end

        def alignment_for(pair)
          if pair.hash_rocket?
            alignment_for_hash_rockets
          else
            alignment_for_colons
          end
        end

        def alignment_for_hash_rockets
          @alignment_for_hash_rockets ||=
            new_alignment('EnforcedHashRocketStyle')
        end

        def alignment_for_colons
          @alignment_for_colons ||=
            new_alignment('EnforcedColonStyle')
        end

        def autocorrect(node)
          # We can't use the instance variable inside the lambda. That would
          # just give each lambda the same reference and they would all get the
          # last value of each. A local variable fixes the problem.
          key_delta = column_deltas[:key] || 0

          if !node.value
            correct_no_value(key_delta, node.source_range)
          else
            correct_key_value(key_delta, node.key.source_range,
                              node.value.source_range,
                              node.loc.operator)
          end
        end

        def correct_no_value(key_delta, key)
          ->(corrector) { adjust(corrector, key_delta, key) }
        end

        def correct_key_value(key_delta, key, value, separator)
          # We can't use the instance variable inside the lambda. That would
          # just give each lambda the same reference and they would all get the
          # last value of each. Some local variables fix the problem.
          separator_delta = column_deltas[:separator] || 0
          value_delta     = column_deltas[:value] || 0

          key_column = key.column
          key_delta = -key_column if key_delta < -key_column

          lambda do |corrector|
            adjust(corrector, key_delta, key)
            adjust(corrector, separator_delta, separator)
            adjust(corrector, value_delta, value)
          end
        end

        def new_alignment(key)
          case cop_config[key]
          when 'key'       then KeyAlignment.new
          when 'table'     then TableAlignment.new
          when 'separator' then SeparatorAlignment.new
          else raise "Unknown #{key}: #{cop_config[key]}"
          end
        end

        def adjust(corrector, delta, range)
          if delta > 0
            corrector.insert_before(range, ' ' * delta)
          elsif delta < 0
            range = range_between(range.begin_pos - delta.abs, range.begin_pos)
            corrector.remove(range)
          end
        end

        def good_alignment?
          column_deltas.values.all?(&:zero?)
        end
      end
    end
  end
end
