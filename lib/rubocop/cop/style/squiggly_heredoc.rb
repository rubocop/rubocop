# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer squiggly heredocs.
      #
      # Squiggly heredocs can be indented like the rest of code without
      # impacting the resulting string, thereby improving readability.
      #
      # NOTE: This cop only checks for places where squiggly heredocs can be
      #       used, but doesn't correct indentation. Indentation is further
      #       corrected by `Layout/HeredocIndentation`.
      #
      # @example
      #   # bad
      #   <<-RUBY
      #   something
      #   RUBY
      #
      #   # good
      #   <<~RUBY
      #   something
      #   RUBY
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: false (default)
      #   # good
      #   <<-RUBY.squish
      #     something
      #   RUBY
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: true
      #   # bad
      #   <<-RUBY.squish
      #     something
      #   RUBY
      #
      #   # good
      #   <<~RUBY.squish
      #     something
      #   RUBY
      #
      class SquigglyHeredoc < Base
        include Heredoc
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.3

        MSG = 'Use squiggly heredoc <<~ instead.'

        # @!method squish_method?(node)
        def_node_matcher :squish_method?, <<~PATTERN
          (send _ {:squish :squish!})
        PATTERN

        def on_heredoc(node)
          return if squiggly_heredoc?(node)

          body = heredoc_body(node)
          return if body.strip.empty?

          body_indent_level = indent_level(body)
          return unless heredoc_squish?(node) || body_indent_level.zero?

          add_offense(node) do |corrector|
            corrected = node.source.sub(/<<-?/, '<<~')
            corrector.replace(node, corrected)
          end
        end

        private

        def heredoc_squish?(node)
          active_support_extensions_enabled? && squish_method?(node.parent)
        end
      end
    end
  end
end
