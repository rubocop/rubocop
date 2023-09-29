# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for single-line `do`...`end` block.
      #
      # In practice a single line `do`...`end` is autocorrected when `EnforcedStyle: semantic`
      # in `Style/BlockDelimiters`. The autocorrection maintains the `do` ... `end` syntax to
      # preserve semantics and does not change it to `{`...`}` block.
      #
      # @example
      #
      #   # bad
      #   foo do |arg| bar(arg) end
      #
      #   # good
      #   foo do |arg|
      #     bar(arg)
      #   end
      #
      #   # bad
      #   ->(arg) do bar(arg) end
      #
      #   # good
      #   ->(arg) { bar(arg) }
      #
      class SingleLineDoEndBlock < Base
        extend AutoCorrector

        MSG = 'Prefer multiline `do`...`end` block.'

        def on_block(node)
          return if !node.single_line? || node.braces?

          add_offense(node) do |corrector|
            corrector.insert_after(do_line(node), "\n")

            node_body = node.body

            if node_body.respond_to?(:heredoc?) && node_body.heredoc?
              corrector.remove(node.loc.end)
              corrector.insert_after(node_body.loc.heredoc_end, "\nend")
            else
              corrector.insert_after(node_body, "\n")
            end
          end
        end
        alias on_numblock on_block

        private

        def do_line(node)
          if node.numblock_type? || node.arguments.children.empty? || node.send_node.lambda_literal?
            node.loc.begin
          else
            node.arguments
          end
        end

        def x(corrector, node); end
      end
    end
  end
end
