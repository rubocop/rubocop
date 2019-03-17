# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of
      # @example
      #   # bad
      #   array = ["a", "b", "c"]
      #   array.compact.flatten.map { |x| x.downcase }
      #
      # Each of these methods (`compact`, `flatten`, `map`) will generate a
      # new intermediate array that is promptly thrown away. Instead it is
      # faster to mutate when we know it's safe.
      #
      # @example
      #   # good.
      #   array = ["a", "b", "c"]
      #   array.compact!
      #   array.flatten!
      #   array.map! { |x| x.downcase }
      #   array
      class ChainArrayAllocation < Cop
        include RangeHelp

        # These methods return a new array but only sometimes. They must be
        # called with an argument. For example:
        #
        #   [1,2].first    # => 1
        #   [1,2].first(1) # => [1]
        #
        RETURN_NEW_ARRAY_WHEN_ARGS = ':first :last :pop :sample :shift '.freeze

        # These methods return a new array only when called without a block.
        RETURNS_NEW_ARRAY_WHEN_NO_BLOCK = ':zip :product '.freeze

        # These methods ALWAYS return a new array
        # after they're called it's safe to mutate the the resulting array
        ALWAYS_RETURNS_NEW_ARRAY = ':* :+ :- :collect :compact :drop '\
                                   ':drop_while :flatten :map :reject ' \
                                   ':reverse :rotate :select :shuffle :sort ' \
                                   ':take :take_while :transpose :uniq ' \
                                   ':values_at :| '.freeze

        # These methods have a mutation alternative. For example :collect
        # can be called as :collect!
        HAS_MUTATION_ALTERNATIVE = ':collect :compact :flatten :map :reject '\
                                   ':reverse :rotate :select :shuffle :sort '\
                                   ':uniq '.freeze
        MSG = 'Use unchained `%<method>s!` and `%<second_method>s!` '\
              '(followed by `return array` if required) instead of chaining '\
              '`%<method>s...%<second_method>s`.'.freeze

        def_node_matcher :flat_map_candidate?, <<-PATTERN
          {
            (send (send _ ${#{RETURN_NEW_ARRAY_WHEN_ARGS}} {int lvar ivar cvar gvar}) ${#{HAS_MUTATION_ALTERNATIVE}} $...)
            (send (block (send _ ${#{ALWAYS_RETURNS_NEW_ARRAY} }) ...) ${#{HAS_MUTATION_ALTERNATIVE}} $...)
            (send (send _ ${#{ALWAYS_RETURNS_NEW_ARRAY + RETURNS_NEW_ARRAY_WHEN_NO_BLOCK}} ...) ${#{HAS_MUTATION_ALTERNATIVE}} $...)
          }
        PATTERN

        def on_send(node)
          flat_map_candidate?(node) do |fm, sm, _|
            range = range_between(
              node.loc.dot.begin_pos,
              node.source_range.end_pos
            )
            add_offense(
              node,
              location: range,
              message: format(MSG, method: fm, second_method: sm)
            )
          end
        end
      end
    end
  end
end
