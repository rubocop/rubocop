# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that your heredocs are using meaningful delimiters. By
      # default it disallows `END`, and can be configured through blacklisting
      # additional delimiters.
      #
      # @example
      #
      #   # good
      #   <<-SQL
      #     SELECT * FROM foo
      #   SQL
      #
      #   # bad
      #   <<-END
      #     SELECT * FROM foo
      #   END
      class HeredocDelimiterNaming < Cop
        MSG = 'Use meaningful heredoc delimiters.'.freeze
        OPENING_DELIMITER = /<<[~-]?'?(\w+)'?\b/

        def on_str(node)
          return unless heredoc?(node) && !meaningful_delimiters?(node)

          add_offense(node, :heredoc_end)
        end
        alias on_dstr on_str
        alias on_xstr on_str

        private

        def heredoc?(node)
          node.loc.is_a?(Parser::Source::Map::Heredoc)
        end

        def meaningful_delimiters?(node)
          !blacklisted_delimiters.include?(delimiters(node))
        end

        def delimiters(node)
          node.source.match(OPENING_DELIMITER).captures.first
        end

        def blacklisted_delimiters
          cop_config['Blacklist'] || []
        end
      end
    end
  end
end
