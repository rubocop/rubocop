# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks the migration for which timestamps are not included
      # when creating a new table.
      # In many cases, timestamps are useful information and should be added.
      #
      # @example
      #   # bad
      #   create_table :users
      #
      #   # bad
      #   create_table :users do |t|
      #     t.string :name
      #     t.string :email
      #   end
      #
      #   # good
      #   create_table :users do |t|
      #     t.string :name
      #     t.string :email
      #
      #     t.timestamps
      #   end
      #
      #   # good
      #   create_table :users do |t|
      #     t.string :name
      #     t.string :email
      #
      #     t.datetime :created_at, default: -> { 'CURRENT_TIMESTAMP' }
      #   end
      #
      #   # good
      #   create_table :users do |t|
      #     t.string :name
      #     t.string :email
      #
      #     t.datetime :updated_at, default: -> { 'CURRENT_TIMESTAMP' }
      #   end
      class CreateTableWithTimestamps < Cop
        MSG = 'Add timestamps when creating a new table.'.freeze

        def_node_matcher :create_table_with_block?, <<-PATTERN
          (block
            (send nil? :create_table ...)
            (args (arg _var))
            _)
        PATTERN

        def_node_matcher :create_table_with_timestamps_proc?, <<-PATTERN
          (send nil? :create_table (sym _) (block-pass (sym :timestamps)))
        PATTERN

        def_node_search :timestamps_included?, <<-PATTERN
          (send _var :timestamps ...)
        PATTERN

        def_node_search :created_at_or_updated_at_included?, <<-PATTERN
          (send _var :datetime (sym {:created_at :updated_at}) ...)
        PATTERN

        def on_send(node)
          return unless node.command?(:create_table)
          parent = node.parent

          if create_table_with_block?(parent)
            if parent.body.nil? || !time_columns_included?(parent.body)
              add_offense(parent)
            end
          elsif create_table_with_timestamps_proc?(node)
            # nothing to do
          else
            add_offense(node)
          end
        end

        private

        def time_columns_included?(node)
          timestamps_included?(node) || created_at_or_updated_at_included?(node)
        end
      end
    end
  end
end
