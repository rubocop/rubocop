# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for all? / any? / none? / one? calls where the block
      # has a single statement and === has been invoked on the receiver so the
      # === argument can be used as the predicate method argument.
      #
      # @example
      #   # bad
      #   %w[foo bar foobar].any? { |e| /oo/.match?(e) }
      #
      #   [1, 2, 3].any? { |e| (1..10).include?(e) }
      #
      #   [1, 2, 3].any? { |e| Set[1, 2, 3] === e }
      #
      #   [1, 2, 3].none? do |e|
      #     Integer === e
      #   end
      #
      #   # good
      #   %w[foo bar foobar].any?(/oo/)
      #
      #   [1, 2, 3].any?(1..10)
      #
      #   [1, 2, 3].any?(Set[1, 2, 3])
      #
      #   [1, 2, 3].none?(Integer)
      #
      class PatternArgument < Base
        include RangeHelp
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.5

        def on_block(node)
          pattern_argument_candidate?(node) do |method, pattern|
            add_offense(
              method.loc.selector,
              message: format(MSG, method: method.method_name, pattern: pattern.source)
            ) do |corrector|
              corrector.replace(block_range_with_space(node), replacement(pattern))
            end
          end
        end

        private

        MSG = 'Pass `%<pattern>s` as an argument to `%<method>s` instead of a block.'

        def_node_matcher :range?, <<~PATTERN
          {(begin ({irange erange} _ _))
           (send (const {nil? cbase} :Range) :new _ _)}
        PATTERN
        def_node_matcher :regexp?, <<~PATTERN
          {(:regexp (:str _) _)
           (send (const {nil? cbase} :Regexp) :new _)}
        PATTERN
        def_node_matcher :set?, '(send (const {nil? cbase} :Set) {:[] :new} ...)'
        def_node_matcher :pattern_argument_candidate?, <<~PATTERN
          (block $({send csend} _ {:all? :any? :none? :one?}) (:args _) {
            (send ${#range? #set?} {:=== :include? :member?} lvar)
            (send ${#regexp?} {:=== :=~ :match :match?} lvar)
            (send $(const nil? _) :=== lvar)
            (send lvar :is_a? $(const nil? _))
            (send lvar {:=~ :match :match?} ${#regexp?})
            (send lvar :=== $(send nil? _))})
        PATTERN

        def replacement(pattern)
          source = pattern.source
          return source if pattern.begin_type? && Array(pattern).first.range_type?

          "(#{source})"
        end

        def block_range_with_space(node)
          block_range = range_between(node.loc.begin.begin_pos, node.loc.end.end_pos)
          range_with_surrounding_space(range: block_range, side: :left)
        end
      end
    end
  end
end
