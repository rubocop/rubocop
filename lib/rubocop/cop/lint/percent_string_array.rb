# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for quotes and commas in %w, e.g.
      #
      #   `%w('foo', "bar")`
      #
      # it is more likely that the additional characters are unintended (for
      # example, mistranslating an array of literals to percent string notation)
      # rather than meant to be part of the resulting strings.
      class PercentStringArray < Cop
        include PercentLiteral

        MSG = "Within `%w`/`%W`, quotes and ',' are unnecessary and may be " \
          'unwanted in the resulting strings.'.freeze

        def on_array(node)
          process(node, '%w', '%W')
        end

        def on_percent_literal(node)
          return unless contains_quotes_or_commas?(node)

          add_offense(node, :expression, MSG)
        end

        private

        def contains_quotes_or_commas?(node)
          patterns = [/,$/, /^'.*'$/, /^".*"$/]

          node.children.any? do |child|
            literal = scrub_string(child.children.first.to_s)

            # To avoid likely false positives (e.g. a single ' or ")
            next if literal.gsub(/[^\p{Alnum}]/, '').empty?

            patterns.any? { |pat| literal =~ pat }
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            node.children.each do |child|
              range = child.loc.expression

              match = /['"]?,?$/.match(range.source)
              corrector.remove_trailing(range, match[0].length) if match

              corrector.remove_leading(range, 1) if /^['"]/ =~ range.source
            end
          end
        end

        def scrub_string(string)
          if string.respond_to?(:scrub)
            string.scrub
          else
            string
              .encode('UTF-16BE', 'UTF-8',
                      invalid: :replace, undef: :replace, replace: '?')
              .encode('UTF-8')
          end
        end
      end
    end
  end
end
