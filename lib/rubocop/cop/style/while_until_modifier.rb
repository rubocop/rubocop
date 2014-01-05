# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for while and until statements that would fit on one line
      # if written as a modifier while/until.
      class WhileUntilModifier < Cop
        include StatementModifier

        MSG =
          'Favor modifier while/until usage when you have a single-line body.'

        def investigate(processed_source)
          return unless processed_source.ast
          on_node([:while, :until], processed_source.ast) do |node|
            # discard modifier while/until
            next unless node.loc.end

            if check(node, processed_source.comments)
              add_offence(node, :keyword)
            end
          end
        end
      end
    end
  end
end
