# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for usage of comparison operators (`==`,
      # `>`, `<`) to test numbers as zero, positive, or negative.
      # These can be replaced by their respective predicate methods.
      # The cop can also be configured to do the reverse.
      #
      # The cop disregards `#nonzero?` as it its value is truthy or falsey,
      # but not `true` and `false`, and thus not always interchangeable with
      # `!= 0`.
      #
      # The cop ignores comparisons to global variables, since they are often
      # populated with objects which can be compared with integers, but are
      # not themselves `Integer` polymorphic.
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
      class NumericPredicate < Cop
        include ConfigurableEnforcedStyle
        include IgnoredMethods

        MSG = 'Use `%<prefer>s` instead of `%<current>s`.'.freeze

        REPLACEMENTS = {
          'zero?' => '==',
          'positive?' => '>',
          'negative?' => '<'
        }.freeze

        def on_send(node)
          return if node.each_ancestor(:send, :block).any? do |ancestor|
            ignored_method?(ancestor.method_name)
          end

          numeric, replacement = check(node)

          return unless numeric

          add_offense(node,
                      message: format(MSG,
                                      prefer: replacement,
                                      current: node.source))
        end

        def autocorrect(node)
          _, replacement = check(node)

          lambda do |corrector|
            corrector.replace(node.loc.expression, replacement)
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

          return unless numeric && operator && replacement_supported?(operator)

          [numeric, replacement(numeric, operator)]
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
          node.send_type? && node.binary_operation? && !node.parenthesized?
        end

        def replacement_supported?(operator)
          if %i[> <].include?(operator)
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
          (send $(...) ${:zero? :positive? :negative?})
        PATTERN

        def_node_matcher :comparison, <<-PATTERN
          (send [$(...) !gvar_type?] ${:== :> :<} (int 0))
        PATTERN

        def_node_matcher :inverted_comparison, <<-PATTERN
          (send (int 0) ${:== :> :<} [$(...) !gvar_type?])
        PATTERN
      end
    end
  end
end
