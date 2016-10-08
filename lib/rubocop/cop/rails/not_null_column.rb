# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for add_column call with NOT NULL constraint
      # in migration file.
      #
      # @example
      #   # bad
      #   add_column :users, :name, :string, null: false
      #
      #   # good
      #   add_column :users, :name, :string, null: true
      #   add_column :users, :name, :string, null: false, default: ''
      class NotNullColumn < Cop
        MSG = 'Do not add a NOT NULL column without a default value.'.freeze

        def_node_matcher :add_not_null_column?, <<-PATTERN
          (send nil :add_column _ _ _ (hash $...))
        PATTERN

        def_node_matcher :null_false?, <<-PATTERN
          (pair (sym :null) (false))
        PATTERN

        def_node_matcher :has_default?, <<-PATTERN
          (pair (sym :default) !(:nil))
        PATTERN

        def on_send(node)
          pairs = add_not_null_column?(node)
          return unless pairs
          return if pairs.any? { |pair| has_default?(pair) }

          null_false = pairs.find { |pair| null_false?(pair) }
          return unless null_false

          add_offense(null_false, :expression)
        end
      end
    end
  end
end
