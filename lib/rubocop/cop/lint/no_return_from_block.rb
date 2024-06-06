# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for blocks that have a return statement.
      # Return statements in blocks are typically an oversight that can lead to bugs.
      #
      # Returns in blocks are ignored by default.
      #
      # @example
      #   # bad
      #   items.each do |item|
      #     return if item.nil?
      #     puts item.some_attribute
      #   end
      #
      #   # good
      #   items.each do |item|
      #     puts item.some_attribute unless item.nil?
      #   end
      #
      #   items.each do |item|
      #     next if item.nil?
      #     puts item.some_attribute
      #   end
      #
      class NoReturnFromBlock < Base
        MSG = 'Return from block detected.'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return if allow_return_from_block?

          node.each_node(:return) do |return_node|
            add_offense(return_node)
          end
        end

        private

        def allow_return_from_block?
          cop_config['AllowReturnFromBlock']
        end
      end
    end
  end
end
