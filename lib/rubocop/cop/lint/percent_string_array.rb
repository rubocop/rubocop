# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for quotes and commas in %w, e.g. `%w('foo', "bar")`
      #
      # It is more likely that the additional characters are unintended (for
      # example, mistranslating an array of literals to percent string notation)
      # rather than meant to be part of the resulting strings.
      #
      # When a quoted string contains whitespace, `%w` splits it into separate values,
      # so removing the quotes would not restore the intended string.
      # Such an array is corrected to an array literal instead, as long as its content
      # reads as one with only string elements.
      #
      # @safety
      #   The cop is unsafe because the correction changes the values in the array
      #   and that might have been done purposely.
      #
      #   [source,ruby]
      #   ----
      #   %w('foo', "bar") #=> ["'foo',", '"bar"']
      #   %w(foo bar)      #=> ['foo', 'bar']
      #   ----
      #
      # @example
      #
      #   # bad
      #   %w('foo', "bar")
      #
      #   # good
      #   %w(foo bar)
      #
      #   # bad - the quoted strings are split at whitespace
      #   %w('foo bar', 'baz')
      #
      #   # good
      #   ['foo bar', 'baz']
      class PercentStringArray < Base
        include PercentLiteral
        extend AutoCorrector

        QUOTES_AND_COMMAS = [/,$/, /^'.*'$/, /^".*"$/].freeze
        LEADING_QUOTE = /^['"]/.freeze
        TRAILING_QUOTE = /['"]?,?$/.freeze

        MSG = "Within `%w`/`%W`, quotes and ',' are unnecessary and may be " \
              'unwanted in the resulting strings.'
        MSG_SPLIT_STRING = 'Within `%w`/`%W`, quoted strings are split at whitespace; ' \
                           'use an array literal instead.'

        def on_array(node)
          process(node, '%w', '%W')
        end

        def on_percent_literal(node)
          if split_quoted_string?(node)
            register_split_quoted_string(node)
          elsif contains_quotes_or_commas?(node)
            register_quotes_or_commas(node)
          end
        end

        private

        def split_quoted_string?(node)
          sources = node.values.map { |value| value.source.delete_suffix(',') }

          sources.each_with_index.any? do |source, index|
            next false unless (quote = unclosed_quote(source))

            sources.drop(index + 1).any? { |rest| closing_quote?(rest, quote) }
          end
        end

        def unclosed_quote(source)
          quote = source[0]
          return unless LEADING_QUOTE.match?(quote)

          quote if source.length > 1 && !source.end_with?(quote)
        end

        def closing_quote?(source, quote)
          source.end_with?(quote) && (source.length == 1 || !source.start_with?(quote))
        end

        def register_split_quoted_string(node)
          add_offense(node, message: MSG_SPLIT_STRING) do |corrector|
            next unless (array_literal = array_literal_source(node))

            corrector.replace(node, array_literal)
          end
        end

        def array_literal_source(node)
          content = range_between(node.loc.begin.end_pos, node.loc.end.begin_pos).source
          array_literal = "[#{content}]"

          array_literal if string_array?(parse(array_literal))
        end

        def string_array?(processed_source)
          return false unless processed_source.valid_syntax? && processed_source.comments.empty?
          return false unless (array = processed_source.ast).array_type?

          array.children.all? { |child| quoted_string?(child) }
        end

        def quoted_string?(node)
          node.type?(:str, :dstr) && node.loc?(:begin)
        end

        def contains_quotes_or_commas?(node)
          node.values.any? do |value|
            literal = value.children.first.to_s.scrub

            # To avoid likely false positives (e.g. a single ' or ")
            next if literal.gsub(/[^[[:alnum:]]]/, '').empty?

            QUOTES_AND_COMMAS.any? { |pat| literal.match?(pat) }
          end
        end

        def register_quotes_or_commas(node)
          add_offense(node) do |corrector|
            node.each_value do |value|
              range = value.source_range

              match = range.source.match(TRAILING_QUOTE)
              corrector.remove_trailing(range, match[0].length) if match

              corrector.remove_leading(range, 1) if LEADING_QUOTE.match?(range.source)
            end
          end
        end
      end
    end
  end
end
