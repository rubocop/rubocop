# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop looks for has_many or has_one associations that don't specify a
      # :dependent option.
      #
      # @example
      #   # bad
      #   class Post < ActiveRecord::Base
      #     has_many :comments
      #   end
      #
      #   # good
      #   class Post < ActiveRecord::Base
      #     has_many :comments, dependent: :destroy
      #   end
      class HasManyDependent < Cop
        MSG = '`has_many` and `has_one` associations must specify a ' \
          '`dependent` option.'.freeze

        def_node_matcher :is_has_many_or_has_one_without_options?, <<-PATTERN
          (send nil {:has_many :has_one} _)
        PATTERN

        def_node_matcher :is_has_many_or_has_one_with_options?, <<-PATTERN
          (send nil {:has_many :has_one} _ (hash $...))
        PATTERN

        def_node_matcher :has_dependent?, <<-PATTERN
          (pair (sym :dependent) !(:nil))
        PATTERN

        def on_send(node)
          unless is_has_many_or_has_one_without_options?(node)
            pairs = is_has_many_or_has_one_with_options?(node)
            return unless pairs
            return if pairs.any? { |pair| has_dependent?(pair) }
          end

          add_offense(node)
        end
      end
    end
  end
end
