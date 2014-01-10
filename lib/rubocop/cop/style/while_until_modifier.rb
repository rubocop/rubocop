# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for while and until statements that would fit on one line
      # if written as a modifier while/until.
      class WhileUntilModifier < Cop
        include StatementModifier

        def investigate(processed_source)
          return unless processed_source.ast
          on_node([:while, :until], processed_source.ast) do |node|
            # discard modifier while/until
            next unless node.loc.end

            if check(node, processed_source.comments)
              add_offence(node, :keyword,
                          message(node.loc.keyword.source))
            end
          end
        end

        private

        def message(keyword)
          "Favor modifier #{keyword} usage when you have a single-line body."
        end
      end
    end
  end
end
