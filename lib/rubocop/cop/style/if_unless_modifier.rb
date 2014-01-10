# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for if and unless statements that would fit on one line
      # if written as a modifier if/unless.
      class IfUnlessModifier < Cop
        include StatementModifier

        def error_message(keyword)
          "Favor modifier #{keyword} usage when you have a single-line body." \
          ' Another good alternative is the usage of control flow &&/||.'
        end

        def investigate(processed_source)
          return unless processed_source.ast
          on_node(:if, processed_source.ast) do |node|
            # discard ternary ops, if/else and modifier if/unless nodes
            next if ternary_op?(node)
            next if modifier_if?(node)
            next if elsif?(node)
            next if if_else?(node)

            if check(node, processed_source.comments)
              add_offence(node, :keyword,
                          error_message(node.loc.keyword.source))
            end
          end
        end
      end
    end
  end
end
