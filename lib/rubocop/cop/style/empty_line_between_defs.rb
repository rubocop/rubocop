# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks whether method definitions are
      # separated by empty lines.
      class EmptyLineBetweenDefs < Cop
        MSG = 'Use empty lines between defs.'

        def on_def(node)
          if @prev_def_end && @prev_def_end < def_end(node) &&
             nothing_or_comments_between_end_and_def?(node)
            unless @prev_was_single_line && single_line_def?(node) &&
                   cop_config['AllowAdjacentOneLineDefs']
              add_offense(node, :keyword)
            end
          end

          @prev_def_end = def_end(node)
          @prev_was_single_line = single_line_def?(node)
        end

        private

        def nothing_or_comments_between_end_and_def?(node)
          distance = def_start(node) - @prev_def_end
          return true if distance == 1

          (@prev_def_end + 1...def_start(node)).all? do |line|
            processed_source.comments.find { |c| c.loc.line == line }
          end
        end

        def single_line_def?(node)
          def_start(node) == def_end(node)
        end

        def def_start(node)
          node.loc.keyword.line
        end

        def def_end(node)
          node.loc.end.line
        end

        def autocorrect(node)
          prev_def = node.ancestors.first.children[node.sibling_index - 1]
          end_pos = prev_def.loc.end.end_pos
          source_buffer = prev_def.loc.end.source_buffer
          newline_pos = source_buffer.source.index("\n", end_pos)
          newline = Parser::Source::Range.new(source_buffer,
                                              newline_pos,
                                              newline_pos + 1)
          ->(corrector) { corrector.insert_after(newline, "\n") }
        end
      end
    end
  end
end
