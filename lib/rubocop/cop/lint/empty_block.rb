# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for blocks without a body.
      # Such empty blocks are typically an oversight or we should provide a comment
      # be clearer what we're aiming for.
      #
      # @example
      #   # bad
      #   items.each { |item| }
      #
      #   # good
      #   items.each { |item| puts item }
      #
      # @example AllowComments: true (default)
      #   # good
      #   items.each do |item|
      #     # TODO: implement later (inner comment)
      #   end
      #
      #   items.each { |item| } # TODO: implement later (inline comment)
      #
      # @example AllowComments: false
      #   # bad
      #   items.each do |item|
      #     # TODO: implement later (inner comment)
      #   end
      #
      #   items.each { |item| } # TODO: implement later (inline comment)
      #
      class EmptyBlock < Base
        MSG = 'Empty block detected.'

        def on_block(node)
          return if node.body
          return if cop_config['AllowComments'] &&
                    processed_source.contains_comment?(node.source_range)

          add_offense(node)
        end
      end
    end
  end
end
