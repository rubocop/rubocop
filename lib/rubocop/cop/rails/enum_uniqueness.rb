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
        MSG = 'Duplicate value `%s` found in `%s` enum declaration.'.freeze

        def_node_matcher :enum_call, <<-END
          (send nil :enum (hash (pair (_ $_) $_)))
        END

        def on_send(node)
          enum_call(node) do |name, args|
            duplicates = duplicates(args.values.map(&:source))

            return if duplicates.empty?

            add_offense(node, :selector,
                        format(MSG, duplicates.join(','), name))
          end
        end

        private

        def duplicates(array)
          array.select { |element| array.count(element) > 1 }.uniq
        end
      end
    end
  end
end
