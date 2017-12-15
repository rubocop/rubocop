# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks for redundant receiver in `with_options`.
      # Receiver is implicit from Rails 4.2 or higher.
      #
      # @example
      #   # bad
      #   class Account < ApplicationRecord
      #     with_options dependent: :destroy do |assoc|
      #       assoc.has_many :customers
      #       assoc.has_many :products
      #       assoc.has_many :invoices
      #       assoc.has_many :expenses
      #     end
      #   end
      #
      #   # good
      #   class Account < ApplicationRecord
      #     with_options dependent: :destroy do
      #       has_many :customers
      #       has_many :products
      #       has_many :invoices
      #       has_many :expenses
      #     end
      #   end
      class RedundantReceiverInWithOptions < Cop
        extend TargetRailsVersion

        minimum_target_rails_version 4.2

        MSG = 'Redundant receiver in `with_options`.'.freeze

        def_node_matcher :with_options?, <<-PATTERN
          (block
            (send nil? :with_options
              (...))
            (args
              (...))
            ...)
        PATTERN

        def_node_search :rails_assoc_with_redundant_receiver, <<-PATTERN
          (send
            (lvar _) {:has_many :has_one :belongs_to :has_and_belongs_to_many} ...)
        PATTERN

        def on_block(node)
          with_options?(node) do
            rails_assoc_with_redundant_receiver(node).each do |assoc|
              add_offense(assoc, location: assoc.receiver.loc.expression)
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.receiver.loc.expression)
            corrector.remove(node.loc.dot)
            corrector.remove(block_argument_range(node))
          end
        end

        private

        def block_argument_range(node)
          block_argument = node.parent.parent.children[1].loc.expression

          range_between(
            search_begin_pos_of_space_before_block_argument(
              block_argument.begin_pos
            ),
            block_argument.end_pos
          )
        end

        def search_begin_pos_of_space_before_block_argument(begin_pos)
          position = begin_pos - 1

          if processed_source.raw_source[position] == ' '
            search_begin_pos_of_space_before_block_argument(position)
          else
            begin_pos
          end
        end
      end
    end
  end
end
