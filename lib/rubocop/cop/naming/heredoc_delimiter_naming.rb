# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop checks that your heredocs are using meaningful delimiters.
      # By default it disallows `END` and `EO*`, and can be configured through
      # forbidden listing additional delimiters.
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

        MSG = 'Use meaningful heredoc delimiters.'

        def on_heredoc(node)
          return if meaningful_delimiters?(node)

          add_offense(node, location: :heredoc_end)
        end

        private

        def meaningful_delimiters?(node)
          delimiters = delimiter_string(node)

          return false unless /\w/.match?(delimiters)

          forbidden_delimiters.none? do |forbidden_delimiter|
            delimiters =~ Regexp.new(forbidden_delimiter)
          end
        end

        def forbidden_delimiters
          cop_config['ForbiddenDelimiters'] || []
        end
      end
    end
  end
end
