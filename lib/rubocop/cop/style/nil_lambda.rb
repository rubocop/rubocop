# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for lambdas and procs that always return nil,
      # which can be replaced with an empty lambda or proc instead.
      #
      # NOTE: A `proc` that returns nil via an explicit `return` is allowed,
      # because in a `proc` `return` exits the enclosing method, so removing it
      # would change behavior. A lambda is still reported, since there `return`
      # only exits the lambda itself.
      #
      # @example
      #   # bad
      #   -> { nil }
      #
      #   lambda do
      #     next nil
      #   end
      #
      #   proc { nil }
      #
      #   Proc.new do
      #     break nil
      #   end
      #
      #   # good
      #   -> {}
      #
      #   lambda do
      #   end
      #
      #   -> (x) { nil if x }
      #
      #   proc {}
      #
      #   Proc.new { nil if x }
      #
      class NilLambda < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Use an empty %<type>s instead of always returning nil.'

        # @!method nil_return?(node)
        def_node_matcher :nil_return?, <<~PATTERN
          { ({return next break} nil) (nil) }
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler, InternalAffairs/ItblockHandler -- a lambda whose body is `nil` uses no parameters
          return unless node.lambda_or_proc?
          return unless nil_return?(node.body)
          # `return` inside a non-lambda proc returns from the enclosing method,
          # so dropping it changes behavior; only a lambda can omit it safely.
          return if node.body.return_type? && !node.lambda?

          message = format(MSG, type: node.lambda? ? 'lambda' : 'proc')
          add_offense(node, message: message) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        def autocorrect(corrector, node)
          body_range = node.body.source_range

          if node.single_line?
            corrector.replace(range_with_surrounding_space(body_range), node.braces? ? '' : ' ')
          elsif own_lines?(body_range)
            corrector.remove(range_by_whole_lines(body_range, include_final_newline: true))
          else
            corrector.remove(body_range_on_shared_line(body_range))
          end
        end

        def own_lines?(range)
          range_by_whole_lines(range).source.strip == range.source
        end

        def body_range_on_shared_line(body_range)
          side = begins_its_line?(body_range) ? :right : :left

          range_with_surrounding_space(body_range, side: side, newlines: false)
        end
      end
    end
  end
end
