# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for the use of the has_and_belongs_to_many macro.
      class HasAndBelongsToMany < Cop
        MSG = 'Prefer `has_many :through` to `has_and_belongs_to_many`.'.freeze

        def on_send(node)
          return unless node.command?(:has_and_belongs_to_many)
          add_offense(node, :selector)
        end
      end
    end
  end
end
