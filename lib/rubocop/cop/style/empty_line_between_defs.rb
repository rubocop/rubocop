# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class EmptyLineBetweenDefs < Cop
        MSG = 'Use empty lines between defs.'

        def on_def(node)
          def_start = node.loc.keyword.line
          def_end = node.loc.end.line

          if @prev_def_end && (def_start - @prev_def_end) < 2
            add_offence(:convention, node.loc.expression, MSG)
          end

          @prev_def_end = def_end

          super
        end
      end
    end
  end
end
