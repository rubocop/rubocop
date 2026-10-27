# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for interpolation in a single quoted string.
      #
      # @safety
      #   This cop's autocorrection is unsafe because although it always replaces single quotes as
      #   if it were miswritten double quotes, it is not always the case. For example,
      #   `'#{foo} bar'` would be replaced by `"#{foo} bar"`, so the replaced code would evaluate
      #   the expression `foo`.
      #
      # @example
      #
      #   # bad
      #   foo = 'something with #{interpolation} inside'
      #
      #   # good
      #   foo = "something with #{interpolation} inside"
      class InterpolationCheck < Base
        extend AutoCorrector

        MSG = 'Interpolation in single quoted string detected. ' \
              'Use double quoted strings if you need interpolation.'

        def on_str(node)
          check(node)
        end

        # A multiline single-quoted string is parsed as a `dstr` of `str` segments, so it
        # is not covered by `on_str`. Inspect single-quoted `dstr`s here; double-quoted
        # interpolation is also a `dstr`, hence the delimiter check.
        def on_dstr(node)
          # A heredoc is also a `dstr`, but its `loc` is a `Parser::Source::Map::Heredoc`
          # with no `begin`, so bail before touching it.
          return if heredoc?(node)

          check(node) if node.loc.begin&.source == "'"
        end

        private

        def check(node)
          return if node.parent&.regexp_type?
          return unless /(?<!\\)#\{.*\}/.match?(node.source)
          return if heredoc?(node)
          return unless single_quoted?(node)
          return unless valid_syntax?(node)

          add_offense(node) { |corrector| autocorrect(corrector, node) }
        end

        def single_quoted?(node)
          node.loc.begin&.is?("'") && node.loc.end
        end

        def autocorrect(corrector, node)
          corrector.replace(node, interpolated_source(node))
        end

        def heredoc?(node)
          node.loc.is_a?(Parser::Source::Map::Heredoc) || (node.parent && heredoc?(node.parent))
        end

        def valid_syntax?(node)
          processed_source = parse(interpolated_source(node))
          processed_source.valid_syntax? && processed_source.ast.dstr_type?
        end

        def interpolated_source(node)
          content = node.source[1...-1]
          return %("#{content}") unless content.include?('"')
          return "%{#{content}}" unless continued_string_part?(node)

          %("#{content.gsub(/\\.|"/) { |m| m == '"' ? '\"' : m }}")
        end

        # A percent literal right after another string part is parsed as the `%` operator.
        def continued_string_part?(node)
          node.parent&.dstr_type? && node.left_sibling
        end
      end
    end
  end
end
