# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This Cop checks whether alter queries are combinable.
      # If combinable queries are detected, it suggests to you
      # to use `change_table` with `bulk: true` instead.
      # This option causes the migration to generate a single
      # ALTER TABLE statement combining multiple column alterations.
      #
      # The `bulk` option is only supported on the MySQL and
      # the PostgreSQL (5.2 later) adapter; thus it will
      # automatically detect an adapter from `development` environment
      # in `config/database.yml` when the `Database` option is not set.
      # If the adapter is not `mysql2` or `postgresql`,
      # this Cop ignores offenses.
      #
      # @example
      #   # bad
      #   def change
      #     add_column :users, :name, :string, null: false
      #     add_column :users, :nickname, :string
      #
      #     # ALTER TABLE `users` ADD `name` varchar(255) NOT NULL
      #     # ALTER TABLE `users` ADD `nickname` varchar(255)
      #   end
      #
      #   # good
      #   def change
      #     change_table :users, bulk: true do |t|
      #       t.string :name, null: false
      #       t.string :nickname
      #     end
      #
      #     # ALTER TABLE `users` ADD `name` varchar(255) NOT NULL,
      #     #                     ADD `nickname` varchar(255)
      #   end
      #
      # @example
      #   # bad
      #   def change
      #     change_table :users do |t|
      #       t.string :name, null: false
      #       t.string :nickname
      #     end
      #   end
      #
      #   # good
      #   def change
      #     change_table :users, bulk: true do |t|
      #       t.string :name, null: false
      #       t.string :nickname
      #     end
      #   end
      #
      #   # good
      #   # When you don't want to combine alter queries.
      #   def change
      #     change_table :users, bulk: false do |t|
      #       t.string :name, null: false
      #       t.string :nickname
      #     end
      #   end
      #
      # @see https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table
      # @see https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html
      class BulkChangeTable < Cop
        MSG_FOR_CHANGE_TABLE = <<-MSG.strip_indent.chomp
          You can combine alter queries using `bulk: true` options.
        MSG
        MSG_FOR_ALTER_METHODS = <<-MSG.strip_indent.chomp
          You can use `change_table :%<table>s, bulk: true` to combine alter queries.
        MSG

        MYSQL = 'mysql'.freeze
        POSTGRESQL = 'postgresql'.freeze

        MIGRATION_METHODS = %i[change up down].freeze

        COMBINABLE_TRANSFORMATIONS = %i[
          primary_key
          column
          string
          text
          integer
          bigint
          float
          decimal
          numeric
          datetime
          timestamp
          time
          date
          binary
          boolean
          json
          virtual
          remove
          change
          timestamps
          remove_timestamps
        ].freeze

        COMBINABLE_ALTER_METHODS = %i[
          add_column
          remove_column
          remove_columns
          change_column
          add_timestamps
          remove_timestamps
        ].freeze

        MYSQL_COMBINABLE_TRANSFORMATIONS = %i[
          rename
          index
          remove_index
        ].freeze

        MYSQL_COMBINABLE_ALTER_METHODS = %i[
          rename_column
          add_index
          remove_index
        ].freeze

        POSTGRESQL_COMBINABLE_TRANSFORMATIONS = %i[
          change_default
        ].freeze

        POSTGRESQL_COMBINABLE_ALTER_METHODS = %i[
          change_column_default
          change_column_null
        ].freeze

        def on_def(node)
          return unless support_bulk_alter?
          return unless MIGRATION_METHODS.include?(node.method_name)
          return unless node.body

          recorder = AlterMethodsRecorder.new

          node.body.each_child_node(:send) do |send_node|
            if combinable_alter_methods.include?(send_node.method_name)
              recorder.process(send_node)
            else
              recorder.flush
            end
          end

          recorder.offensive_nodes.each { |n| add_offense_for_alter_methods(n) }
        end

        def on_send(node)
          return unless support_bulk_alter?
          return unless node.command?(:change_table)
          return if include_bulk_options?(node)
          return unless node.block_node

          send_nodes = node.block_node.body.each_child_node(:send).to_a

          transformations = send_nodes.select do |send_node|
            combinable_transformations.include?(send_node.method_name)
          end

          add_offense_for_change_table(node) if transformations.size > 1
        end

        private

        # @param node [RuboCop::AST::SendNode] (send nil? :change_table ...)
        def include_bulk_options?(node)
          # arguments: [{(sym :table)(str "table")} (hash (pair (sym :bulk) _))]
          options = node.arguments[1]
          return false unless options

          options.hash_type? &&
            options.keys.any? { |key| key.sym_type? && key.value == :bulk }
        end

        def database
          cop_config['Database'] || database_from_yaml
        end

        def database_from_yaml
          return nil unless database_yaml

          case database_yaml['adapter']
          when 'mysql2'
            MYSQL
          when 'postgresql'
            POSTGRESQL
          end
        end

        def database_yaml
          return nil unless File.exist?('config/database.yml')

          yaml = YAML.load_file('config/database.yml')
          return nil unless yaml.is_a? Hash

          config = yaml['development']
          return nil unless config.is_a?(Hash)

          config
        rescue Psych::SyntaxError
          nil
        end

        def support_bulk_alter?
          case database
          when MYSQL
            true
          when POSTGRESQL
            # Add bulk alter support for PostgreSQL in 5.2.0
            # @see https://github.com/rails/rails/pull/31331
            target_rails_version >= 5.2
          else
            false
          end
        end

        def combinable_alter_methods
          case database
          when MYSQL
            COMBINABLE_ALTER_METHODS + MYSQL_COMBINABLE_ALTER_METHODS
          when POSTGRESQL
            COMBINABLE_ALTER_METHODS + POSTGRESQL_COMBINABLE_ALTER_METHODS
          end
        end

        def combinable_transformations
          case database
          when MYSQL
            COMBINABLE_TRANSFORMATIONS + MYSQL_COMBINABLE_TRANSFORMATIONS
          when POSTGRESQL
            COMBINABLE_TRANSFORMATIONS + POSTGRESQL_COMBINABLE_TRANSFORMATIONS
          end
        end

        # @param node [RuboCop::AST::SendNode]
        def add_offense_for_alter_methods(node)
          # arguments: [{(sym :table)(str "table")} ...]
          table_node = node.arguments[0]
          return unless table_node.is_a? RuboCop::AST::BasicLiteralNode

          message = format(MSG_FOR_ALTER_METHODS, table: table_node.value)
          add_offense(node, message: message)
        end

        # @param node [RuboCop::AST::SendNode]
        def add_offense_for_change_table(node)
          add_offense(node, message: MSG_FOR_CHANGE_TABLE)
        end

        # Record combinable alter methods and register offensive nodes.
        class AlterMethodsRecorder
          def initialize
            @nodes = []
            @offensive_nodes = []
          end

          # @param new_node [RuboCop::AST::SendNode]
          def process(new_node)
            # arguments: [{(sym :table)(str "table")} ...]
            table_node = new_node.arguments[0]
            if table_node.is_a? RuboCop::AST::BasicLiteralNode
              flush unless @nodes.all? do |node|
                node.arguments[0].value.to_s == table_node.value.to_s
              end
              @nodes << new_node
            else
              flush
            end
          end

          def flush
            @offensive_nodes << @nodes.first if @nodes.size > 1
            @nodes = []
          end

          def offensive_nodes
            flush
            @offensive_nodes
          end
        end
      end
    end
  end
end
