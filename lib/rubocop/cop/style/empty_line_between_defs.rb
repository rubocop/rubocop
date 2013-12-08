# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether method definitions are
      # separated by empty lines.
      class EmptyLineBetweenDefs < Cop
        MSG = 'Use empty lines between defs.'

        def on_def(node)
          if @prev_def_end && (def_start(node) - @prev_def_end) == 1
            unless @prev_was_single_line && singe_line_def?(node) &&
                cop_config['AllowAdjacentOneLineDefs']
              add_offence(node, :keyword)
            end
          end

          @prev_def_end = def_end(node)
          @prev_was_single_line = singe_line_def?(node)
        end

        private

        def singe_line_def?(node)
          def_start(node) == def_end(node)
        end

        def def_start(node)
          node.loc.keyword.line
        end

        def def_end(node)
          node.loc.end.line
        end
      end
    end
  end
end
