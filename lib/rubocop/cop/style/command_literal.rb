# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop enforces using `` or %x around command literals.
      #
      # @example EnforcedStyle: backticks (default)
      #   # bad
      #   folders = %x(find . -type d).split
      #
      #   # bad
      #   %x(
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   )
      #
      #   # good
      #   folders = `find . -type d`.split
      #
      #   # good
      #   `
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   `
      #
      # @example EnforcedStyle: mixed
      #   # bad
      #   folders = %x(find . -type d).split
      #
      #   # bad
      #   `
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   `
      #
      #   # good
      #   folders = `find . -type d`.split
      #
      #   # good
      #   %x(
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   )
      #
      # @example EnforcedStyle: percent_x
      #   # bad
      #   folders = `find . -type d`.split
      #
      #   # bad
      #   `
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   `
      #
      #   # good
      #   folders = %x(find . -type d).split
      #
      #   # good
      #   %x(
      #     ln -s foo.example.yml foo.example
      #     ln -s bar.example.yml bar.example
      #   )
      #
      # @example AllowInnerBackticks: false (default)
      #   # If `false`, the cop will always recommend using `%x` if one or more
      #   # backticks are found in the command string.
      #
      #   # bad
      #   `echo \`ls\``
      #
      #   # good
      #   %x(echo `ls`)
      #
      # @example AllowInnerBackticks: true
      #   # good
      #   `echo \`ls\``
      class CommandLiteral < Cop
        include ConfigurableEnforcedStyle

        MSG_USE_BACKTICKS = 'Use backticks around command string.'.freeze
        MSG_USE_PERCENT_X = 'Use `%x` around command string.'.freeze

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
          return if allowed_backtick_literal?(node)

          add_offense(node)
        end

        def check_percent_x_literal(node)
          return if allowed_percent_x_literal?(node)

          add_offense(node)
        end

        def message(node)
          backtick_literal?(node) ? MSG_USE_PERCENT_X : MSG_USE_BACKTICKS
        end

        def allowed_backtick_literal?(node)
          case style
          when :backticks
            !contains_disallowed_backtick?(node)
          when :mixed
            node.single_line? && !contains_disallowed_backtick?(node)
          end
        end

        def allowed_percent_x_literal?(node)
          case style
          when :backticks
            contains_disallowed_backtick?(node)
          when :mixed
            node.multiline? || contains_disallowed_backtick?(node)
          when :percent_x
            true
          end
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

        def preferred_delimiters
          config.for_cop('Style/PercentLiteralDelimiters') \
            ['PreferredDelimiters']['%x'].split(//)
        end

        def autocorrect(node)
          return if contains_backtick?(node)

          replacement = if backtick_literal?(node)
                          ['%x', ''].zip(preferred_delimiters).map(&:join)
                        else
                          %w[` `]
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
