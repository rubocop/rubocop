# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for invalid character literals with a non-escaped
      # whitespace character (e.g. `? `).
      # However, currently it's unclear whether there's a way to emit this
      # warning without syntax errors.
      #
      #     $ ruby -w
      #     p(? )
      #     -:1: warning: invalid character syntax; use ?\s
      #     -:1: syntax error, unexpected '?', expecting ')'
      #     p(? )
      #        ^
      #
      # @example
      #   p(? )
      class InvalidCharacterLiteral < Cop
        include ParserDiagnostic

        private

        def relevant_diagnostic?(diagnostic)
          diagnostic.reason == :invalid_escape_use
        end

        def alternative_message(diagnostic)
          diagnostic
            .message
            .capitalize
            .gsub('character syntax', 'character literal')
        end
      end
    end
  end
end
