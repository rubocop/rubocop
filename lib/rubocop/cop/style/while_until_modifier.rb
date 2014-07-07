# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for while and until statements that would fit on one line
      # if written as a modifier while/until.
      # The maximum line length is configurable.
      class WhileUntilModifier < Cop
        include StatementModifier

        def investigate(processed_source)
          return unless processed_source.ast
          on_node([:while, :until], processed_source.ast) do |node|
            # discard modifier while/until
            next unless node.loc.end
            next unless fit_within_line_as_modifier_form?(node)
            add_offense(node, :keyword, message(node.loc.keyword.source))
          end
        end

        private

        def message(keyword)
          "Favor modifier `#{keyword}` usage when having a single-line body."
        end
      end
    end
  end
end
