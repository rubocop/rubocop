# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop checks that your heredocs are using meaningful delimiters.
      # By default it disallows `END` and `EO*`, and can be configured through
      # blacklisting additional delimiters.
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
      #
      #   # bad
      #   <<-EOS
      #     SELECT * FROM foo
      #   EOS
      class HeredocDelimiterNaming < Cop
        include Heredoc

        MSG = 'Use meaningful heredoc delimiters.'.freeze
        OPENING_DELIMITER = /<<[~-]?'?(\w+)'?\b/

        def on_heredoc(node)
          return if meaningful_delimiters?(node)

          add_offense(node, :heredoc_end)
        end

        private

        def meaningful_delimiters?(node)
          delimiters = delimiters(node)

          blacklisted_delimiters.none? do |blacklisted_delimiter|
            delimiters =~ Regexp.new(blacklisted_delimiter)
          end
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
