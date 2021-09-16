# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of comparison operators (`==`,
      # `>`, `<`) to test numbers as zero, positive, or negative.
      # These can be replaced by their respective predicate methods.
      # The cop can also be configured to do the reverse.
      #
      # The cop disregards `#nonzero?` as its value is truthy or falsey,
      # but not `true` and `false`, and thus not always interchangeable with
      # `!= 0`.
      #
      # The cop ignores comparisons to global variables, since they are often
      # populated with objects which can be compared with integers, but are
      # not themselves `Integer` polymorphic.
      #
      # @safety
      #   This cop is unsafe because it cannot be guaranteed that the receiver
      #   defines the predicates or can be compared to a number, which may lead
      #   to a false positive for non-standard classes.
      #
      # @example EnforcedStyle: predicate (default)
      #   # bad
      #
      #   foo == 0
      #   0 > foo
      #   bar.baz > 0
      #
      #   # good
      #
      #   foo.zero?
      #   foo.negative?
      #   bar.baz.positive?
      #
      # @example EnforcedStyle: comparison
      #   # bad
      #
      #   foo.zero?
      #   foo.negative?
      #   bar.baz.positive?
      #
      #   # good
      #
      #   foo == 0
      #   0 > foo
      #   bar.baz > 0
      class NumericPredicate < Base
        include ConfigurableEnforcedStyle
        include IgnoredMethods
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'

        REPLACEMENTS = { 'zero?' => '==', 'positive?' => '>', 'negative?' => '<' }.freeze

        RESTRICT_ON_SEND = %i[== > < positive? negative? zero?].freeze

        def on_send(node)
          numeric, replacement = check(node)
          return unless numeric

          return if ignored_method?(node.method_name) ||
                    node.each_ancestor(:send, :block).any? do |ancestor|
                      ignored_method?(ancestor.method_name)
                    end

          message = format(MSG, prefer: replacement, current: node.source)
          add_offense(node, message: message) do |corrector|
            corrector.replace(node, replacement)
          end
        end

        private

        def check(node)
          numeric, operator =
            if style == :predicate
              comparison(node) || inverted_comparison(node, &invert)
            else
              predicate(node)
            end

          return unless numeric && operator

          [numeric, replacement(numeric, operator)]
        end

        def replacement(numeric, operation)
          if style == :predicate
            [parenthesized_source(numeric), REPLACEMENTS.invert[operation.to_s]].join('.')
          else
            [numeric.source, REPLACEMENTS[operation.to_s], 0].join(' ')
          end
        end

        def parenthesized_source(node)
          if require_parentheses?(node)
            "(#{node.source})"
          else
            node.source
          end
        end

        def require_parentheses?(node)
          node.send_type? && node.binary_operation? && !node.parenthesized?
        end

        def invert
          lambda do |comparison, numeric|
            comparison = { :> => :<, :< => :> }[comparison] || comparison

            [numeric, comparison]
          end
        end

        # @!method predicate(node)
        def_node_matcher :predicate, <<~PATTERN
          (send $(...) ${:zero? :positive? :negative?})
        PATTERN

        # @!method comparison(node)
        def_node_matcher :comparison, <<~PATTERN
          (send [$(...) !gvar_type?] ${:== :> :<} (int 0))
        PATTERN

        # @!method inverted_comparison(node)
        def_node_matcher :inverted_comparison, <<~PATTERN
          (send (int 0) ${:== :> :<} [$(...) !gvar_type?])
        PATTERN
      end
    end
  end
end
