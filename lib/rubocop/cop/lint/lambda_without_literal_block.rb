# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks uses of lambda without a literal block.
      # It emulates the following warning in Ruby 3.0:
      #
      #   % ruby -vwe 'lambda(&proc {})'
      #   ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin19]
      #   -e:1: warning: lambda without a literal block is deprecated; use the proc without
      #   lambda instead
      #
      # This way, proc object is never converted to lambda.
      # Auto-correction replaces with compatible proc argument.
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

        def on_send(node)
          return if node.parent&.block_type? || !node.first_argument

          add_offense(node) do |corrector|
            corrector.replace(node, node.first_argument.source.delete('&'))
          end
        end
      end
    end
  end
end
