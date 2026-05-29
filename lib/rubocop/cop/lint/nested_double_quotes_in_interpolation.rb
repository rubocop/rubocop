# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for double-quoted strings that contain interpolations with
      # double-quoted strings, which can be hard to read and understand.
      #
      # @example EnforcedStyle: percent_q (default)
      #
      #   # bad
      #   "#{success? ? "yes" : "no"}"
      #   "#{"hello #{name}"}"
      #
      #   # good
      #   "#{success? ? 'yes' : 'no'}"
      #   "#{%Q(hello #{name})}"
      #
      # @example EnforcedStyle: double_quotes
      #
      #   # bad
      #   "#{success? ? "yes" : "no"}"
      #
      #   # good
      #   "#{success? ? 'yes' : 'no'}"
      #   "#{"hello #{name}"}"
      class NestedDoubleQuotesInInterpolation < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG_PERCENT_Q = 'Nesting double-quotes makes code hard to read; ' \
                        'use single-quotes or `%Q(...)` inside interpolations.'
        MSG_DOUBLE_QUOTES = 'Nesting double-quotes makes code hard to read; ' \
                            'use single-quotes inside interpolations.'

        def on_str(node)
          check(node)
        end

        def on_dstr(node)
          check(node)
        end

        private

        def check(node)
          return unless node.loc?(:begin)
          return unless nested_in_double_quoted_interpolation?(node)
          return unless double_quote_delimiter?(node)
          return if node.dstr_type? && double_quotes_style?

          add_offense(node, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end

        def nested_in_double_quoted_interpolation?(node)
          interpolation_begin = node.each_ancestor(:begin).find do |ancestor|
            ancestor.parent&.type?(:dstr, :dsym, :regexp, :xstr)
          end
          return false unless interpolation_begin

          outer_literal = interpolation_begin.parent
          return true if double_quote_delimiter?(outer_literal)

          percent_array = interpolation_begin.each_ancestor(:array).find do |ancestor|
            percent_interpolated_array_literal?(ancestor)
          end
          return false unless percent_array

          double_quote_delimiter?(percent_array)
        end

        def percent_interpolated_array_literal?(node)
          delimiter(node).start_with?('%W', '%I')
        end

        def double_quote_delimiter?(node)
          delimiter(node)&.end_with?('"')
        end

        def delimiter(node)
          return unless node.loc?(:begin)

          node.loc.begin.source
        end

        def autocorrect(corrector, node)
          if node.str_type? && correctable_str?(node)
            replace_delimiters(corrector, node, "'", "'")
          elsif !double_quotes_style? && balanced_parentheses?(node)
            replace_delimiters(corrector, node, '%Q(', ')')
          end
        end

        def correctable_str?(node)
          content = node.source[1..-2]
          !content.include?('\\') && !content.include?("'")
        end

        def balanced_parentheses?(node)
          source = node.source[1..-2]
          source.count('(') == source.count(')')
        end

        def replace_delimiters(corrector, node, opening, closing)
          corrector.replace(node.loc.begin, opening)
          corrector.replace(node.loc.end, closing)
        end

        def message
          double_quotes_style? ? MSG_DOUBLE_QUOTES : MSG_PERCENT_Q
        end

        def double_quotes_style?
          style == :double_quotes
        end
      end
    end
  end
end
