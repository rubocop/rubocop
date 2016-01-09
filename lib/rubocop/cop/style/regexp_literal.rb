# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop enforces using // or %r around regular expressions.
      #
      # @example
      #   # Good if EnforcedStyle is slashes or mixed, bad if percent_r.
      #   snake_case = /^[\dA-Z_]+$/
      #
      #   # Good if EnforcedStyle is percent_r, bad if slashes or mixed.
      #   snake_case = %r{^[\dA-Z_]+$}
      #
      #   # Good if EnforcedStyle is slashes, bad if percent_r or mixed.
      #   regex = /
      #     foo
      #     (bar)
      #     (baz)
      #   /x
      #
      #   # Good if EnforcedStyle is percent_r or mixed, bad if slashes.
      #   regex = %r{
      #     foo
      #     (bar)
      #     (baz)
      #   }x
      #
      #   # Bad unless AllowInnerSlashes is true.
      #   x =~ /home\//
      class RegexpLiteral < Cop
        include ConfigurableEnforcedStyle

        MSG_USE_SLASHES = 'Use `//` around regular expression.'.freeze
        MSG_USE_PERCENT_R = 'Use `%r` around regular expression.'.freeze

        def on_regexp(node)
          if slash_literal?(node)
            check_slash_literal(node)
          else
            check_percent_r_literal(node)
          end
        end

        private

        def check_slash_literal(node)
          return if style == :slashes && !contains_disallowed_slash?(node)
          return if style == :mixed &&
                    node.single_line? &&
                    !contains_disallowed_slash?(node)

          add_offense(node, :expression, MSG_USE_PERCENT_R)
        end

        def check_percent_r_literal(node)
          return if style == :slashes && contains_disallowed_slash?(node)
          return if style == :percent_r
          return if style == :mixed && node.multiline?
          return if style == :mixed && contains_disallowed_slash?(node)

          add_offense(node, :expression, MSG_USE_SLASHES)
        end

        def contains_disallowed_slash?(node)
          !allow_inner_slashes? && contains_slash?(node)
        end

        def contains_slash?(node)
          node_body(node).include?('/')
        end

        def allow_inner_slashes?
          cop_config['AllowInnerSlashes']
        end

        def node_body(node)
          string_parts = node.children.select { |child| child.type == :str }
          string_parts.map(&:source).join
        end

        def slash_literal?(node)
          node.loc.begin.source == '/'
        end

        def preferred_delimiters
          config.for_cop('Style/PercentLiteralDelimiters') \
            ['PreferredDelimiters']['%r'].split(//)
        end

        def autocorrect(node)
          return if contains_slash?(node)

          replacement = if slash_literal?(node)
                          ['%r', ''].zip(preferred_delimiters).map(&:join)
                        else
                          %w(/ /)
                        end

          lambda do |corrector|
            corrector.replace(node.loc.begin, replacement.first)
            corrector.replace(node.loc.end, replacement.last)
          end
        end
      end
    end
  end
end
