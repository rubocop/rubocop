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
      #   # good
      #   enum status: [:active, :archived]
      class EnumUniqueness < Cop
        MSG = 'Duplicate value `%s` found in `%s` enum declaration.'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node

          return unless method_name == :enum

          enum_name, enum_opts = parse_args(args)

          return if enum_opts.type == :array

          enum_values = enum_opts.each_child_node.map do |child_node|
            child_node.child_nodes.last.source
          end

          dupes = arr_dupes(enum_values)
          return if dupes.empty?

          add_offense(node, :selector, format(MSG, dupes.join(','), enum_name))
        end

        private

        def arr_dupes(array)
          array.select { |element| array.count(element) > 1 }.uniq
        end

        def parse_args(args)
          enum_config = args.first.each_child_node.first.child_nodes

          enum_name = enum_config.first.source
          enum_opts = enum_config.last

          [enum_name, enum_opts]
        end
      end
    end
  end
end
