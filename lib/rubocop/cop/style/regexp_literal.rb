# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces using // or %r around regular expressions, and
      # prevents unnecessary /-escapes inside %r literals.
      #
      # @example EnforcedStyle: slashes (default)
      #   # bad
      #   snake_case = %r{^[\dA-Z_]+$}
      #
      #   # bad
      #   regex = %r{
      #     foo
      #     (bar)
      #     (baz)
      #   }x
      #
      #   # good
      #   snake_case = /^[\dA-Z_]+$/
      #
      #   # good
      #   regex = /
      #     foo
      #     (bar)
      #     (baz)
      #   /x
      #
      # @example EnforcedStyle: percent_r
      #   # bad
      #   snake_case = /^[\dA-Z_]+$/
      #
      #   # bad
      #   regex = /
      #     foo
      #     (bar)
      #     (baz)
      #   /x
      #
      #   # good
      #   snake_case = %r{^[\dA-Z_]+$}
      #
      #   # good
      #   regex = %r{
      #     foo
      #     (bar)
      #     (baz)
      #   }x
      #
      # @example EnforcedStyle: mixed
      #   # bad
      #   snake_case = %r{^[\dA-Z_]+$}
      #
      #   # bad
      #   regex = /
      #     foo
      #     (bar)
      #     (baz)
      #   /x
      #
      #   # good
      #   snake_case = /^[\dA-Z_]+$/
      #
      #   # good
      #   regex = %r{
      #     foo
      #     (bar)
      #     (baz)
      #   }x
      #
      # @example AllowInnerSlashes: false (default)
      #   # If `false`, the cop will always recommend using `%r` if one or more
      #   # slashes are found in the regexp string.
      #
      #   # bad
      #   x =~ /home\//
      #
      #   # good
      #   x =~ %r{home/}
      #
      # @example AllowInnerSlashes: true
      #   # good
      #   x =~ /home\//
      #
      # @example
      #   # bad
      #   r = %r{foo\/bar}
      #
      #   # good
      #   r = %r{foo/bar}
      #
      #   # good
      #   r = %r/foo\/bar/
      class RegexpLiteral < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG_USE_SLASHES = 'Use `//` around regular expression.'
        MSG_USE_PERCENT_R = 'Use `%r` around regular expression.'
        MSG_UNNECESSARY_ESCAPE = 'Unnecessary `/`-escape inside `%r` literal'

        def on_regexp(node)
          if slash_literal?(node)
            check_slash_literal(node)
          else
            check_percent_r_literal(node)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            if !slash_literal?(node) && allowed_percent_r_literal?(node)
              correct_inner_slashes(node, corrector, '\/', '/')
            else
              correct_delimiters(node, corrector)
              correct_inner_slashes(
                node,
                corrector,
                inner_slash_before_delimiter_correction(node),
                inner_slash_after_delimiter_correction(node)
              )
            end
          end
        end

        private

        def check_slash_literal(node)
          return if allowed_slash_literal?(node)

          add_offense(node, message: MSG_USE_PERCENT_R)
        end

        def check_percent_r_literal(node)
          if allowed_percent_r_literal?(node)
            percent_r_unnecessary_escapes(node).each do |loc|
              add_offense(node, location: loc, message: MSG_UNNECESSARY_ESCAPE)
            end
          else
            add_offense(node, message: MSG_USE_SLASHES)
          end
        end

        def allowed_slash_literal?(node)
          style == :slashes && !contains_disallowed_slash?(node) ||
            allowed_mixed_slash?(node)
        end

        def allowed_mixed_slash?(node)
          style == :mixed && node.single_line? &&
            !contains_disallowed_slash?(node)
        end

        def allowed_percent_r_literal?(node)
          style == :slashes && contains_disallowed_slash?(node) ||
            style == :percent_r ||
            allowed_mixed_percent_r?(node)
        end

        def allowed_mixed_percent_r?(node)
          style == :mixed && node.multiline? ||
            contains_disallowed_slash?(node)
        end

        def contains_disallowed_slash?(node)
          !allow_inner_slashes? && contains_slash?(node)
        end

        def contains_slash?(node)
          node_body(node).include?('/')
        end

        def percent_r_unnecessary_escapes(node)
          return [] if percent_r_slash_delimiters?(node) || allow_inner_slashes?

          inner_slash_ranges(node, '\/')
        end

        def allow_inner_slashes?
          cop_config['AllowInnerSlashes']
        end

        def node_body(node, include_begin_nodes: false)
          types = include_begin_nodes ? %i[str begin] : %i[str]
          node.each_child_node(*types).map(&:source).join
        end

        def slash_literal?(node)
          node.loc.begin.source == '/'
        end

        def percent_r_slash_delimiters?(node)
          node.loc.begin.source == '%r/'
        end

        def preferred_delimiters
          config.for_cop('Style/PercentLiteralDelimiters') \
            ['PreferredDelimiters']['%r'].split(//)
        end

        def correct_delimiters(node, corrector)
          replacement = calculate_replacement(node)
          corrector.replace(node.loc.begin, replacement.first)
          corrector.replace(node.loc.end, replacement.last)
        end

        def correct_inner_slashes(node, corrector, existing, replacement)
          inner_slash_ranges(node, existing).map do |range|
            corrector.replace(range, replacement)
          end
        end

        def inner_slash_ranges(node, slash)
          regexp_begin = node.loc.begin.end_pos

          inner_slash_indices(node, slash).map do |index|
            start = regexp_begin + index

            range_between(start, start + slash.length)
          end
        end

        def inner_slash_indices(node, pattern)
          text    = node_body(node, include_begin_nodes: true)
          index   = -1
          indices = []

          while (index = text.index(pattern, index + 1))
            indices << index
          end

          indices
        end

        def inner_slash_before_delimiter_correction(node)
          inner_slash_for(node.loc.begin.source)
        end

        def inner_slash_after_delimiter_correction(node)
          inner_slash_for(calculate_replacement(node).first)
        end

        def inner_slash_for(opening_delimiter)
          if ['/', '%r/'].include?(opening_delimiter)
            '\/'
          else
            '/'
          end
        end

        def calculate_replacement(node)
          if slash_literal?(node)
            ['%r', ''].zip(preferred_delimiters).map(&:join)
          else
            %w[/ /]
          end
        end
      end
    end
  end
end
