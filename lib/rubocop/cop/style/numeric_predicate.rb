# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of comparison operators (`==`, `!=`,
      # `>`, `<`) to test numbers as zero, nonzero, positive, or negative.
      # These can be replaced by their respective predicate methods.
      # The cop can also be configured to do the reverse.
      #
      # @example
      #
      #   # EnforcedStyle: predicate (default)
      #
      #   # bad
      #
      #   foo == 0
      #   0 != bar.baz
      #   0 > foo
      #   bar.baz > 0
      #
      #   # good
      #
      #   foo.zero?
      #   bar.baz.nonzero?
      #   foo.negative?
      #   bar.baz.positive?
      #
      # @example
      #
      #   # EnforcedStyle: comparison
      #
      #   # bad
      #
      #   foo.zero?
      #   bar.baz.nonzero?
      #   foo.negative?
      #   bar.baz.positive?
      #
      #   # good
      #
      #   foo == 0
      #   0 != bar.baz
      #   0 > foo
      #   bar.baz > 0
      class NumericPredicate < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Use `%s` instead of `%s`.'.freeze

        REPLACEMENTS = {
          'zero?' => '==',
          'nonzero?' => '!=',
          'positive?' => '>',
          'negative?' => '<'
        }.freeze

        def on_send(node)
          numeric, replacement = check(node)

          return unless numeric

          add_offense(node, node.loc.expression,
                      format(MSG, replacement, node.source))
        end

        private

        def check(node)
          numeric, operator =
            if style == :predicate
              comparison(node) || inverted_comparison(node, &invert)
            else
              predicate(node)
            end

          return unless numeric && operator && replacement_supported?(operator)

          [numeric, replacement(numeric, operator)]
        end

        def autocorrect(node)
          _, replacement = check(node)

          lambda do |corrector|
            corrector.replace(node.loc.expression, replacement)
          end
        end

        def replacement(numeric, operation)
          if style == :predicate
            [parenthesized_source(numeric),
             REPLACEMENTS.invert[operation.to_s]].join('.')
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
          node.binary_operation? && node.source !~ /^\(.*\)$/
        end

        def replacement_supported?(operator)
          if [:>, :<].include?(operator)
            target_ruby_version >= 2.3
          else
            true
          end
        end

        def invert
          lambda do |comparison, numeric|
            comparison = { :> => :<, :< => :> }[comparison] || comparison

            [numeric, comparison]
          end
        end

        def_node_matcher :predicate, <<-PATTERN
          (send $(...) ${:zero? :nonzero? :positive? :negative?})
        PATTERN

        def_node_matcher :comparison, <<-PATTERN
          (send $(...) ${:== :!= :> :<} (int 0))
        PATTERN

        def_node_matcher :inverted_comparison, <<-PATTERN
          (send (int 0) ${:== :!= :> :<} $(...))
        PATTERN
      end
    end
  end
end
