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

        def on_block(node)
          return if node.multiline? || node.braces?
          return if single_line_blocks_preferred? && suitable_as_single_line?(node)

          add_offense(node) do |corrector|
            if (heredoc = heredoc_opened_before_do(node))
              # Code after the `end`, such as a method chain, would be left behind after the `do`.
              next if code_after_end?(node.loc.end)

              move_body_after_heredoc(corrector, node, heredoc)
            else
              break_block_body(corrector, node)
            end
          end
        end
        alias on_numblock on_block
        alias on_itblock on_block

        private

        def single_line_blocks_preferred?
          @config.for_enabled_cop('Layout/RedundantLineBreak')['InspectBlocks']
        end

        def code_after_end?(end_keyword)
          rest = end_keyword.source_line[end_keyword.last_column..].strip

          !rest.empty? && !rest.start_with?('#')
        end

        def move_body_after_heredoc(corrector, node, heredoc)
          body = node.body

          corrector.remove(do_line(node).end.join(node.loc.end.end))
          corrector.insert_after(heredoc.loc.heredoc_end, "\n#{body.source}") if body

          last_heredoc = trailing_heredoc(body) || heredoc
          corrector.insert_after(last_heredoc.loc.heredoc_end, "\nend")
        end

        def break_block_body(corrector, node)
          corrector.insert_after(do_line(node), "\n")

          if (heredoc = trailing_heredoc(node.body))
            corrector.remove(node.loc.end)
            corrector.insert_after(heredoc.loc.heredoc_end, "\nend")
          else
            corrector.insert_before(node.loc.end, "\n")
          end
        end

        # Returns the heredoc opened before the `do` on the block's line whose body extends
        # the furthest down. It can be opened outside the block, such as in a preceding argument.
        def heredoc_opened_before_do(node)
          do_begin_pos = node.loc.begin.begin_pos

          heredocs = processed_source.ast.each_node(:any_str).select do |str_node|
            heredoc_opened_on_line_before?(str_node, node.first_line, do_begin_pos)
          end

          heredocs.max_by { |heredoc| heredoc.loc.heredoc_end.line }
        end

        def heredoc_opened_on_line_before?(str_node, line, pos)
          return false unless str_node.heredoc?

          str_node.first_line == line && str_node.source_range.end_pos <= pos
        end

        def do_line(node)
          if node.type?(:numblock, :itblock) ||
             node.arguments.children.empty? || node.send_node.lambda_literal?
            node.loc.begin
          else
            node.arguments.source_range
          end
        end

        def trailing_heredoc(root)
          return unless root

          heredocs = root.each_node(:any_str).select(&:heredoc?)

          heredocs.max_by { |heredoc| heredoc.loc.heredoc_end.line }
        end
      end
    end
  end
end
