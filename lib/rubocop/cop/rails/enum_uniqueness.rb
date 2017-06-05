# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for duplicate values in enum declarations.
      #
      # @example
      #   # bad
      #   enum status: { active: 0, archived: 0 }
      #
      #   # good
      #   enum status: { active: 0, archived: 1 }
      #
      #   # bad
      #   enum status: [:active, :archived, :active]
      #
      #   # good
      #   enum status: [:active, :archived]
      class EnumUniqueness < Cop
        include Duplication

        MSG = 'Duplicate value `%s` found in `%s` enum declaration.'.freeze

        def_node_matcher :enum_declaration, <<-PATTERN
          (send nil :enum (hash (pair (_ $_) ${array hash})))
        PATTERN

        def on_send(node)
          enum_declaration(node) do |name, args|
            items = args.values

            return unless duplicates?(items)

            consecutive_duplicates(items).each do |item|
              add_offense(item, :expression, format(MSG, item.source, name))
            end
          end
        end
      end
    end
  end
end
