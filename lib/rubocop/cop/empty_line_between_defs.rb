# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLineBetweenDefs < Cop
      MSG = 'Use empty lines between defs.'

      def inspect(file, source, tokens, ast)
        prev_def_end = nil

        on_node(:def, ast) do |s|
          def_start = s.src.keyword.line
          def_end = s.src.end.line

          if prev_def_end && (def_start - prev_def_end) < 2
            add_offence(:convention,
                        def_start,
                        MSG)
          end

          prev_def_end = def_end
        end
      end
    end
  end
end
