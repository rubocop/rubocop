# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for two or more consecutive blank lines.
      class EmptyLinesAroundBody < Cop
        MSG_BEG = 'Extra blank line detected at body beginning.'
        MSG_END = 'Extra blank line detected at body end.'

        def on_class(node)
          check_node(node)
        end

        def on_module(node)
          check_node(node)
        end

        def on_sclass(node)
          check_node(node)
        end

        def on_def(node)
          check_node(node)
        end

        def on_defs(node)
          check_node(node)
        end

        private

        def check_node(node)
          start_line = node.loc.keyword.line
          end_line = node.loc.end.line

          return if start_line == end_line

          check_source(start_line, end_line)
        end

        def check_source(start_line, end_line)
          if processed_source.lines[start_line].blank?
            range = source_range(processed_source.buffer,
                                 processed_source[0...start_line],
                                 0,
                                 1)
            convention(nil, range, MSG_BEG)
          end

          if processed_source.lines[end_line - 2].blank?
            range = source_range(processed_source.buffer,
                                 processed_source[0...(end_line - 2)],
                                 0,
                                 1)
            convention(nil, range, MSG_END)
          end
        end
      end
    end
  end
end
