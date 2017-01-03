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
          enum_call(node) do |enum_name, enum_args|
            dupes = arr_dupes(enum_values(enum_args))
            return if dupes.empty?

            add_offense(node, :selector,
                        format(MSG, dupes.join(','), enum_name))
          end
        end

        private

        def enum_values(enum_args)
          if enum_args.array_type?
            enum_array_keys(enum_args)
          else
            enum_hash_values(enum_args)
          end
        end

        def enum_array_keys(array_node)
          array_node.each_child_node.map(&:source)
        end

        def enum_hash_values(hash_node)
          hash_node.values.map(&:source)
        end

        def arr_dupes(array)
          array.select { |element| array.count(element) > 1 }.uniq
        end
      end
    end
  end
end
