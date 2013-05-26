# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLineBetweenDefs < Cop
      MSG = 'Use empty lines between defs.'

      def on_def(s)
        def_start = s.loc.keyword.line
        def_end = s.loc.end.line

        if @prev_def_end && (def_start - @prev_def_end) < 2
          add_offence(:convention, def_start, MSG)
        end

        @prev_def_end = def_end

        super
      end
    end
  end
end
