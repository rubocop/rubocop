# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for double-quoted strings that contain interpolations with
      # double-quoted strings, which can be hard to read and understand.
      #
      # @example
      #
      #   # bad
      #   "#{success? ? "yes" : "no"}"
      #
      #   # good
      #   "#{success? ? 'yes' : 'no'}"
      class NestedDoubleQuotesInInterpolation < Cop
        MSG =
          'Nesting double-quotes makes strings hard to read; switch ' \
          'to single-quotes.'.freeze

        def on_str(node)
          return unless inside_interpolation?(node)
          return if inside_heredoc?(node)
          return if inside_percent_literal_with_interpolation?(node)
          return unless double_quoted?(node)

          add_offense(node)
        end

        def inside_interpolation?(node)
          # A :begin node inside a :dstr node is an interpolation.
          node.ancestors.drop_while { |a| !a.begin_type? }.any?(&:dstr_type?)
        end

        def inside_heredoc?(node)
          node.ancestors.any? do |ancestor_node|
            ancestor_node.loc.is_a?(Parser::Source::Map::Heredoc)
          end
        end

        def inside_percent_literal_with_interpolation?(node)
          node.ancestors.any? do |ancestor_node|
            ancestor_node.source.start_with?('%', '%Q')
          end
        end

        def double_quoted?(node)
          node.source.start_with?('"')
        end
      end
    end
  end
end
