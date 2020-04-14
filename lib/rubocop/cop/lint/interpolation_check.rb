# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for interpolation in a single quoted string.
      #
      # @example
      #
      #   # bad
      #
      #   foo = 'something with #{interpolation} inside'
      #
      # @example
      #
      #   # good
      #
      #   foo = "something with #{interpolation} inside"
      class InterpolationCheck < Cop
        MSG = 'Interpolation in single quoted string detected. '\
              'Use double quoted strings if you need interpolation.'

        def on_str(node)
          return if heredoc?(node)

          parent = node.parent
          return if parent && (parent.dstr_type? || parent.regexp_type?)
          return unless /(?<!\\)#\{.*\}/.match?(node.source.scrub)

          add_offense(node)
        end

        def heredoc?(node)
          node.loc.is_a?(Parser::Source::Map::Heredoc) ||
            (node.parent && heredoc?(node.parent))
        end
      end
    end
  end
end
