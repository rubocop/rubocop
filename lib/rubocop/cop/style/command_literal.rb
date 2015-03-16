# encoding: utf-8

require 'forwardable'

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
          Node.new(node, self).check
        end

        private

        def autocorrect(node)
          replacement = Node.new(node, self).replacement

          @corrections << lambda do |corrector|
            corrector.replace(node.loc.begin, replacement.first)
            corrector.replace(node.loc.end, replacement.last)
          end
        end

        # Wrapper class for CommandLiteral-specific code for a node instance.
        class Node
          include Util
          extend Forwardable
          def_delegators :@cop, :style, :config, :cop_config, :add_offense

          def initialize(node, cop)
            @node, @cop = node, cop
          end

          attr_reader :node

          def check
            return if heredoc_literal?

            if backtick_literal?
              check_backtick_literal
            else
              check_percent_x_literal
            end
          end

          def check_backtick_literal
            return if style == :backticks && !contains_disallowed_backtick?
            return if style == :mixed &&
                      single_line? &&
                      !contains_disallowed_backtick?

            add_offense(node, :expression, MSG_USE_PERCENT_X)
          end

          def check_percent_x_literal
            return if style == :backticks && contains_disallowed_backtick?
            return if style == :percent_x
            return if style == :mixed && multi_line?
            return if style == :mixed && contains_disallowed_backtick?

            add_offense(node, :expression, MSG_USE_BACKTICKS)
          end

          def contains_disallowed_backtick?
            !allow_inner_backticks? && contains_backtick?
          end

          def allow_inner_backticks?
            cop_config['AllowInnerBackticks']
          end

          def contains_backtick?
            node_body =~ /`/
          end

          def node_body
            loc = node.loc
            loc.expression.source[loc.begin.length...-loc.end.length]
          end

          def heredoc_literal?
            node.loc.respond_to?(:heredoc_body)
          end

          def backtick_literal?
            node.loc.begin.source == '`'
          end

          def single_line?
            !multi_line?
          end

          def multi_line?
            block_length(node) > 1
          end

          def preferred_delimiters
            config.for_cop('Style/PercentLiteralDelimiters') \
              ['PreferredDelimiters']['%x'].split(//)
          end

          def replacement
            fail CorrectionNotPossible if contains_backtick?

            if backtick_literal?
              ['%x', ''].zip(preferred_delimiters).map(&:join)
            else
              %w(` `)
            end
          end
        end
      end
    end
  end
end
