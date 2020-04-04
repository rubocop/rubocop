# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether trailing commas in block arguments are
      # required. Blocks with only one argument and a trailing comma require
      # that comma to be present. Blocks with more than one argument never
      # require a trailing comma.
      #
      # @example
      #   # bad
      #   add { |foo, bar,| foo + bar }
      #
      #    # good
      #   add { |foo, bar| foo + bar }
      #
      #   # good
      #   add { |foo,| foo }
      #
      #   # good
      #   add { foo }
      #
      #   # bad
      #  add do |foo, bar,|
      #    foo + bar
      #   end
      #
      #  # good
      #  add do |foo, bar|
      #    foo + bar
      #  end
      #
      #  # good
      #   add do |foo,|
      #    foo
      #  end
      #
      #  # good
      #  add do
      #     foo + bar
      #  end
      class TrailingCommaInBlockArgs < Cop
        MSG = 'Useless trailing comma present in block arguments.'

        def on_block(node)
          # lambda literal (`->`) never has block arguments.
          return if node.send_node.lambda_literal?

          return unless useless_trailing_comma?(node)

          add_offense(node, location: last_comma(node).pos)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(last_comma(node).pos, '') }
        end

        private

        def useless_trailing_comma?(node)
          arg_count(node) > 1 && trailing_comma?(node)
        end

        def arg_count(node)
          node.arguments.each_descendant(:arg, :optarg, :kwoptarg).to_a.size
        end

        def trailing_comma?(node)
          argument_tokens(node).last.comma?
        end

        def last_comma(node)
          argument_tokens(node).last
        end

        def argument_tokens(node)
          pipes = tokens(node).select { |token| token.type == :tPIPE }
          begin_pos, end_pos = pipes.map do |pipe|
            tokens(node).index(pipe)
          end

          tokens(node)[begin_pos + 1..end_pos - 1]
        end
      end
    end
  end
end
