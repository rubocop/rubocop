# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for strings that contain escaped single or double quotes,
      # and suggests removing them by changing the string quotation style
      # or using `%q` or `%Q` macros.
      #
      # The resulting string may not confirm with the desired style set in
      # `Style/StringLiterals`, although that cop will not register an offense
      # after correcting. If desired, `EnforcedStyle: always_percent_literal` can
      # be set to prefer percent literals instead.
      #
      # NOTE: This cop detects offenses within interpolated strings, but does not
      # correct them.
      #
      # @example EnforcedStyle: prefer_quoted_strings (default)
      #   # bad
      #   'foo\'bar'
      #
      #   # good
      #   "foo'bar"
      #
      #   # bad
      #   "foo\"bar"
      #
      #   # good
      #   'foo"bar'
      #
      #   # bad - both quote types are used within the string
      #   'foo\'bar"baz'
      #
      #   # good
      #   %q{foo'bar"baz}
      #
      # @example EnforcedStyle: always_percent_literal
      #   # bad
      #   'foo\'bar'
      #
      #   # good
      #   %q{foo'bar}
      #
      #   # bad
      #   "foo\"bar"
      #
      #   # good
      #   %q{foo\"bar}
      #
      #   # bad
      #   'foo\'bar"baz'
      #
      #   # good
      #   %q{foo'bar"baz}
      class EscapedQuotes < Base
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG = 'Avoid escaping quotes within quoted string literals.'
        LINE_CONTINUATION = '\\'

        def on_str(node)
          return if part_of_ignored_node?(node)
          return unless offense?(node)

          correction_style = correction_style(node)

          if uncorrectable?(node, correction_style)
            add_offense(offense_range(node))
          else
            add_offense(node) do |corrector|
              autocorrect(corrector, node, correction_style)
            end
          end
        end

        def on_regexp(node)
          ignore_node(node)
        end

        private

        def offense?(node)
          # If the string is a double-quoted multiline string that contains an escaped
          # double quotes, the escape is required.
          return !continuation?(node) if escaped_double_quote_in_dstr?(node)
          return false unless node.single_quoted? || node.double_quoted?

          contains_escape?(node)
        end

        def uncorrectable?(node, correction_style)
          node.parent&.dstr_type? &&
            (!node.loc.begin || correction_style == :percent_literal)
        end

        def escaped_double_quote_in_dstr?(node)
          return false unless node.parent&.dstr_type?
          return false unless node.parent.double_quoted?

          node.value['"']
        end

        def contains_escape?(node)
          (node.single_quoted? && node.value["'"]) ||
            (node.double_quoted? && node.value['"'])
        end

        def continuation?(node)
          return false if processed_source.line_with_comment?(processed_source.ast.last_line)

          last_line = processed_source.lines[node.last_line - 1]
          last_line.end_with?(LINE_CONTINUATION)
        end

        def autocorrect(corrector, node, correction_style)
          if correction_style == :percent_literal
            corrected_percent_literal(corrector, node)
          else
            StringLiteralCorrector.correct(corrector, node, correction_style)
          end
        end

        def correction_style(node)
          return :percent_literal if style == :always_percent_literal

          source = node.value
          single_quote = source["'"]
          double_quote = source['"']

          if double_quote && (single_quote || needs_escaping?(source))
            :percent_literal
          elsif single_quote
            :double_quotes
          elsif double_quote
            :single_quotes
          end
        end

        def corrected_percent_literal(corrector, node)
          open, close = PreferredDelimiters.new('%q', config, nil).delimiters
          replacement = "%q#{open}#{escape_string(node.str_content)}#{close}"

          corrector.replace(node, replacement)
        end

        def offense_range(node)
          node.loc?(:begin) ? node : node.parent
        end
      end
    end
  end
end
