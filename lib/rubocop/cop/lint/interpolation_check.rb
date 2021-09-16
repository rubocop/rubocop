# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for interpolation in a single quoted string.
      #
      # @safety
      #   This cop is generally safe, but is marked as unsafe because
      #   it is possible to actually intentionally have text inside
      #   `#{...}` in a single quoted string.
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
      class InterpolationCheck < Base
        extend AutoCorrector

        MSG = 'Interpolation in single quoted string detected. '\
              'Use double quoted strings if you need interpolation.'

        def on_str(node)
          return if node.parent&.regexp_type?
          return unless /(?<!\\)#\{.*\}/.match?(node.source)
          return if heredoc?(node)
          return unless node.loc.begin && node.loc.end

          add_offense(node) { |corrector| autocorrect(corrector, node) }
        end

        private

        def autocorrect(corrector, node)
          starting_token, ending_token = if node.source.include?('"')
                                           ['%{', '}']
                                         else
                                           ['"', '"']
                                         end

          corrector.replace(node.loc.begin, starting_token)
          corrector.replace(node.loc.end, ending_token)
        end

        def heredoc?(node)
          node.loc.is_a?(Parser::Source::Map::Heredoc) || (node.parent && heredoc?(node.parent))
        end
      end
    end
  end
end
