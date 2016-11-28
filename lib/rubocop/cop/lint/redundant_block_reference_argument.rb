# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for a redundant block reference argument.
      # Such arguments should be omitted.
      #
      # @example
      #
      #   @bad
      #   def foo(&_)
      #   end
      #
      #   @good
      #   def foo
      #   end
      class RedundantBlockReferenceArgument < Cop
        MSG = 'Found redundant block reference argument. Omit it.'.freeze

        def redundant_block_arg?(node)
          name, = *node
          name == :_
        end

        def on_blockarg(node)
          return unless redundant_block_arg?(node)

          add_offense(node, :expression, MSG)
        end

        private

        def autocorrect(node)
          range = range_with_surrounding_comma(
            range_with_surrounding_space(node.location.expression, :left),
            :left
          )

          lambda do |corrector|
            corrector.remove(range)
          end
        end
      end
    end
  end
end
