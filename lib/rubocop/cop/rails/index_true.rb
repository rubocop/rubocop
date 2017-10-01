# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Check that index: true is not being used in add_column
      # or change_column statement. This option functions as
      # expected in a create_table statement, but silently
      # fails in other migration statements.
      #
      # @example
      #   # bad
      #   add_column :booking_templates, :booking_id, :integer, index: true
      #
      #   # good
      #   add_column :booking_templates, :booking_id, :integer
      #
      #   # Remember to add the index separately
      #   add_index :booking_templates, :booking_id
      #
      class IndexTrue < Cop
        MSG = '`index: true` does not work in an `add_column` ' \
        'or `change_column` method. ' \
        'Please use `add_index :table, :column`.'.freeze

        def_node_matcher :no_index_true, <<-PATTERN
          (send nil {:add_column :change_column} _table _column _type (hash $...))
        PATTERN

        def on_send(node)
          no_index_true(node) do |args|
            if index_option_passed?(args)
              add_offense(node, :expression, format(MSG))
            end
          end
        end

        def index_option_passed?(args)
          pair_node, = *args
          key, = *pair_node.key
          key == :index
        end
      end
    end
  end
end
