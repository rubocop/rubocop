# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Prefer using `Hash#compare_by_identity` than using `object_id` for hash keys.
      #
      # This cop is marked as unsafe as a hash possibly can contain other keys
      # besides `object_id`s.
      #
      # @example
      #   # bad
      #   hash = {}
      #   hash[foo.object_id] = :bar
      #   hash.key?(baz.object_id)
      #
      #   # good
      #   hash = {}.compare_by_identity
      #   hash[foo] = :bar
      #   hash.key?(baz)
      #
      class HashCompareByIdentity < Base
        RESTRICT_ON_SEND = %i[key? has_key? fetch [] []=].freeze

        MSG = 'Use `Hash#compare_by_identity` instead of using `object_id` for keys.'

        def_node_matcher :id_as_hash_key?, <<~PATTERN
          (send _ {:key? :has_key? :fetch :[] :[]=} (send _ :object_id) ...)
        PATTERN

        def on_send(node)
          add_offense(node) if id_as_hash_key?(node)
        end
      end
    end
  end
end
