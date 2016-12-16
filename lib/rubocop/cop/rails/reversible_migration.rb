# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks whether the change method of the migration file is
      # reversible.
      #
      # @example
      #   # bad
      #   def change
      #     change_table :users do |t|
      #       t.column :name, :string
      #     end
      #   end
      #
      #   # good
      #   def change
      #     create_table :users do |t|
      #       t.string :name
      #     end
      #   end
      #
      #   # good
      #   def change
      #     reversible do |dir|
      #       change_table :users do |t|
      #         dir.up do
      #           t.column :name, :string
      #         end
      #
      #         dir.down do
      #           t.remove :name
      #         end
      #       end
      #     end
      #   end
      #
      # @example
      #   # drop_table
      #
      #   # bad
      #   def change
      #     drop_table :users
      #   end
      #
      #   # good
      #   def change
      #     drop_table :users do |t|
      #       t.string :name
      #     end
      #   end
      #
      # @example
      #   # change_column_default
      #
      #   # bad
      #   def change
      #     change_column_default(:suppliers, :qualification, 'new')
      #   end
      #
      #   # good
      #   def change
      #     change_column_default(:posts, :state, from: nil, to: "draft")
      #   end
      #
      # @example
      #   # remove_column
      #
      #   # bad
      #   def change
      #     remove_column(:suppliers, :qualification)
      #   end
      #
      #   # good
      #   def change
      #     remove_column(:suppliers, :qualification, :string)
      #   end
      #
      # @example
      #   # remove_foreign_key
      #
      #   # bad
      #   def change
      #     remove_foreign_key :accounts, column: :owner_id
      #   end
      #
      #   # good
      #   def change
      #     remove_foreign_key :accounts, :branches
      #   end
      #
      # @see http://api.rubyonrails.org/classes/ActiveRecord/Migration/CommandRecorder.html
      class ReversibleMigration < Cop
        MSG = '%s is not reversible.'.freeze

        def_node_matcher :irreversible_schema_statement_call, <<-END
          (send nil ${:change_table :change_table_comment :execute :remove_belongs_to} ...)
        END

        def_node_matcher :drop_table_call, <<-END
          (send nil :drop_table ...)
        END

        def_node_matcher :change_column_default_call, <<-END
          (send nil :change_column_default _ _ $...)
        END

        def_node_matcher :remove_column_call, <<-END
          (send nil :remove_column $...)
        END

        def_node_matcher :remove_foreign_key_call, <<-END
          (send nil :remove_foreign_key _ $_)
        END

        def on_send(node)
          return unless within_change_method?(node)
          return if within_reversible_block?(node)

          check_irreversible_schema_statement_node(node)
          check_drop_table_node(node)
          check_change_column_default_node(node)
          check_remove_column_node(node)
          check_remove_foreign_key_node(node)
        end

        private

        def check_irreversible_schema_statement_node(node)
          irreversible_schema_statement_call(node) do |method_name|
            add_offense(node, :expression, format(MSG, method_name))
          end
        end

        def check_drop_table_node(node)
          drop_table_call(node) do
            unless node.parent.block_type?
              add_offense(
                node, :expression,
                format(MSG, 'drop_table(without block)')
              )
            end
          end
        end

        def check_change_column_default_node(node)
          change_column_default_call(node) do |args|
            unless all_hash_key?(args.first, :from, :to)
              add_offense(
                node, :expression,
                format(MSG, 'change_column_default(without :from and :to)')
              )
            end
          end
        end

        def check_remove_column_node(node)
          remove_column_call(node) do |args|
            if args.to_a.size < 3
              add_offense(
                node, :expression,
                format(MSG, 'remove_column(without type)')
              )
            end
          end
        end

        def check_remove_foreign_key_node(node)
          remove_foreign_key_call(node) do |arg|
            if arg.hash_type?
              add_offense(
                node, :expression,
                format(MSG, 'remove_foreign_key(without table)')
              )
            end
          end
        end

        def within_change_method?(node)
          parent = node.parent
          while parent
            if parent.def_type?
              method_name, = *parent
              return true if method_name == :change
            end
            parent = parent.parent
          end
          false
        end

        def within_reversible_block?(node)
          parent = node.parent
          while parent
            if parent.block_type?
              _, block_name = *parent.to_a.first
              return true if block_name == :reversible
            end
            parent = parent.parent
          end
          false
        end

        def all_hash_key?(args, *keys)
          return false unless args
          return false unless args.hash_type?

          hash_keys = args.to_a.map do |arg|
            arg.to_a.first.children.first.to_sym
          end

          hash_keys & keys == keys
        end
      end
    end
  end
end
