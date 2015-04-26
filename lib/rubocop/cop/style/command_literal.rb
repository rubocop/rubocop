# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop enforces using `` or %x around command literals.
      #
      # @example
      #   # Good if EnforcedStyle is backticks or mixed, bad if percent_x.
      #   folders = `find . -type d`.split
      #
      #   # Good if EnforcedStyle is percent_x, bad if backticks or mixed.
      #   folders = %x(find . -type d).split
      #
      #   # Good if EnforcedStyle is backticks, bad if percent_x or mixed.
      #   `
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   `
      #
      #   # Good if EnforcedStyle is percent_x or mixed, bad if backticks.
      #   %x(
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   )
      #
      #   # Bad unless AllowInnerBackticks is true.
      #   `echo \`ls\``
      class CommandLiteral < Cop
        include ConfigurableEnforcedStyle

        MSG_USE_BACKTICKS = 'Use backticks around command string.'
        MSG_USE_PERCENT_X = 'Use `%x` around command string.'

        def on_xstr(node)
          return if heredoc_literal?(node)

          if backtick_literal?(node)
            check_backtick_literal(node)
          else
            check_percent_x_literal(node)
          end
        end

        private

        def check_backtick_literal(node)
          return if style == :backticks && !contains_disallowed_backtick?(node)
          return if style == :mixed &&
                    single_line?(node) &&
                    !contains_disallowed_backtick?(node)

          add_offense(node, :expression, MSG_USE_PERCENT_X)
        end

        def check_percent_x_literal(node)
          return if style == :backticks && contains_disallowed_backtick?(node)
          return if style == :percent_x
          return if style == :mixed && multi_line?(node)
          return if style == :mixed && contains_disallowed_backtick?(node)

          add_offense(node, :expression, MSG_USE_BACKTICKS)
        end

        def contains_disallowed_backtick?(node)
          !allow_inner_backticks? && contains_backtick?(node)
        end

        def allow_inner_backticks?
          cop_config['AllowInnerBackticks']
        end

        def contains_backtick?(node)
          node_body(node) =~ /`/
        end

        def node_body(node)
          loc = node.loc
          loc.expression.source[loc.begin.length...-loc.end.length]
        end

        def heredoc_literal?(node)
          node.loc.respond_to?(:heredoc_body)
        end

        def backtick_literal?(node)
          node.loc.begin.source == '`'
        end

        def single_line?(node)
          !multi_line?(node)
        end

        def multi_line?(node)
          block_length(node) > 1
        end

        def preferred_delimiters
          config.for_cop('Style/PercentLiteralDelimiters') \
            ['PreferredDelimiters']['%x'].split(//)
        end

        def autocorrect(node)
          return if contains_backtick?(node)

          if backtick_literal?(node)
            replacement = ['%x', ''].zip(preferred_delimiters).map(&:join)
          else
            replacement = %w(` `)
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
