# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for quotes and commas in %w, e.g. `%w('foo', "bar")`
      #
      # It is more likely that the additional characters are unintended (for
      # example, mistranslating an array of literals to percent string notation)
      # rather than meant to be part of the resulting strings.
      #
      # @example
      #
      #   # bad
      #
      #   %w('foo', "bar")
      #
      # @example
      #
      #   # good
      #
      #   %w(foo bar)
      class PercentStringArray < Cop
        include PercentLiteral

        QUOTES_AND_COMMAS = [/,$/, /^'.*'$/, /^".*"$/].freeze
        LEADING_QUOTE = /^['"]/
        TRAILING_QUOTE = /['"]?,?$/

        MSG = "Within `%w`/`%W`, quotes and ',' are unnecessary and may be " \
          'unwanted in the resulting strings.'.freeze

        def on_array(node)
          process(node, '%w', '%W')
        end

        def on_percent_literal(node)
          return unless contains_quotes_or_commas?(node)

          add_offense(node)
        end

        private

        def contains_quotes_or_commas?(node)
          node.values.any? do |value|
            literal = value.children.first.to_s.scrub

            # To avoid likely false positives (e.g. a single ' or ")
            next if literal.gsub(/[^\p{Alnum}]/, '').empty?

            QUOTES_AND_COMMAS.any? { |pat| literal =~ pat }
          end
        end

        # rubocop:disable Performance/HashEachMethods
        def autocorrect(node)
          lambda do |corrector|
            node.values.each do |value|
              range = value.loc.expression

              match = range.source.match(TRAILING_QUOTE)
              corrector.remove_trailing(range, match[0].length) if match

              if range.source =~ LEADING_QUOTE
                corrector.remove_leading(range, 1)
              end
            end
          end
        end
        # rubocop:enable Performance/HashEachMethods
      end
    end
  end
end
