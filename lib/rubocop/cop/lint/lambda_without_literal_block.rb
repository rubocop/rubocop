# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks uses of lambda without a literal block.
      # It emulates the following warning in Ruby 3.0:
      #
      #   $ ruby -vwe 'lambda(&proc {})'
      #   ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin19]
      #   -e:1: warning: lambda without a literal block is deprecated; use the proc without
      #   lambda instead
      #
      # This way, proc object is never converted to lambda.
      # Autocorrection replaces with compatible proc argument.
      #
      # @example
      #
      #   # bad
      #   lambda(&proc { do_something })
      #   lambda(&Proc.new { do_something })
      #
      #   # good
      #   proc { do_something }
      #   Proc.new { do_something }
      #   lambda { do_something } # If you use lambda.
      #
      class LambdaWithoutLiteralBlock < Base
        extend AutoCorrector

        MSG = 'lambda without a literal block is deprecated; use the proc without lambda instead.'
        RESTRICT_ON_SEND = %i[lambda].freeze

        # @!method lambda_with_symbol_proc?(node)
        def_node_matcher :lambda_with_symbol_proc?, <<~PATTERN
          (send nil? :lambda (block_pass (sym _)))
        PATTERN

        def on_send(node)
          argument = node.first_argument
          return if node.parent&.block_type? || !argument || lambda_with_symbol_proc?(node)

          add_offense(node) do |corrector|
            next if unsafe_to_unwrap?(node, argument)

            corrector.replace(node, argument.source.delete_prefix('&'))
          end
        end

        private

        def unsafe_to_unwrap?(node, argument)
          return false if node.single_line?

          processed_source.tokens_within(node).any? do |token|
            next if argument.source_range.contains?(token.pos)

            token.comment? || token.type == :tSTRING_END
          end
        end
      end
    end
  end
end
