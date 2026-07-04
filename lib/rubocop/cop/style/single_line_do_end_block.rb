# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for single-line `do`...`end` block.
      #
      # In practice a single line `do`...`end` is autocorrected when `EnforcedStyle: semantic`
      # is configured for `Style/BlockDelimiters`. The autocorrection maintains the
      # `do` ... `end` syntax to preserve semantics and does not change it to `{`...`}` block.
      #
      # NOTE: If `InspectBlocks` is set to `true` for `Layout/RedundantLineBreak`, blocks will
      # be autocorrected to be on a single line if possible. This cop respects that configuration
      # by not registering an offense if it would subsequently cause a
      # `Layout/RedundantLineBreak` offense.
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
        include CheckSingleLineSuitability

        MSG = 'Prefer multiline `do`...`end` block.'

        # rubocop:disable Metrics/AbcSize
        def on_block(node)
          return if node.multiline? || node.braces?
          return if single_line_blocks_preferred? && suitable_as_single_line?(node)

          add_offense(node) do |corrector|
            corrector.insert_after(do_line(node), "\n")

            if (heredoc = trailing_heredoc(node.body))
              # The heredoc body extends past the `end` on the source, so the
              # `end` has to be moved after it rather than before, which would
              # otherwise move it into the heredoc body and break the syntax.
              corrector.remove(node.loc.end)
              corrector.insert_after(heredoc.loc.heredoc_end, "\nend")
            else
              corrector.insert_before(node.loc.end, "\n")
            end
          end
        end
        # rubocop:enable Metrics/AbcSize
        alias on_numblock on_block
        alias on_itblock on_block

        private

        # Returns the heredoc opened on the block's line whose body extends the
        # furthest down, whether it is the block body itself or nested within it.
        def trailing_heredoc(node_body)
          return unless node_body

          heredocs = [node_body, *node_body.each_descendant].select do |node|
            node.respond_to?(:heredoc?) && node.heredoc?
          end

          heredocs.max_by { |heredoc| heredoc.loc.heredoc_end.line }
        end

        def do_line(node)
          if node.type?(:numblock, :itblock) ||
             node.arguments.children.empty? || node.send_node.lambda_literal?
            node.loc.begin
          else
            node.arguments
          end
        end

        def single_line_blocks_preferred?
          @config.for_enabled_cop('Layout/RedundantLineBreak')['InspectBlocks']
        end
      end
    end
  end
end
