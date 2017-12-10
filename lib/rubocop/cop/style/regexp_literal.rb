# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces using // or %r around regular expressions.
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

        def autocorrect(node)
          return if contains_slash?(node)

          replacement = if slash_literal?(node)
                          ['%r', ''].zip(preferred_delimiters).map(&:join)
                        else
                          %w[/ /]
                        end

          lambda do |corrector|
            corrector.replace(node.loc.begin, replacement.first)
            corrector.replace(node.loc.end, replacement.last)
          end
        end

        private

        def check_slash_literal(node)
          return if allowed_slash_literal?(node)

          add_offense(node, message: MSG_USE_PERCENT_R)
        end

        def check_percent_r_literal(node)
          return if allowed_percent_r_literal?(node)

          add_offense(node, message: MSG_USE_SLASHES)
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

        def allow_inner_slashes?
          cop_config['AllowInnerSlashes']
        end

        def node_body(node)
          node.each_child_node(:str).map(&:source).join
        end

        def slash_literal?(node)
          node.loc.begin.source == '/'
        end

        def preferred_delimiters
          config.for_cop('Style/PercentLiteralDelimiters') \
            ['PreferredDelimiters']['%r'].split(//)
        end
      end
    end
  end
end
