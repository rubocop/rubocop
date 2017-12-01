# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for working with heredoc strings.
    module Heredoc
      OPENING_DELIMITER = /<<[~-]?['"`]?([^'"`]+)['"`]?/

      def on_str(node)
        return unless node.heredoc?

        on_heredoc(node)
      end
      alias on_dstr on_str
      alias on_xstr on_str

      def on_heredoc(_node)
        raise NotImplementedError
      end

      private

      def delimiter_string(node)
        node.source.match(OPENING_DELIMITER).captures.first
      end
    end
  end
end
