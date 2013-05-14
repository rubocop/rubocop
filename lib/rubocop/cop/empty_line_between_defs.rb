# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLineBetweenDefs < Cop
      ERROR_MESSAGE = 'Use empty lines between defs.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        prev_def_end = nil

        on_node(:def, sexp) do |s|
          def_start = s.src.keyword.line
          def_end = s.src.end.line

          if prev_def_end && (def_start - prev_def_end) < 2
            add_offence(:convention,
                        def_start,
                        ERROR_MESSAGE)
          end

          prev_def_end = def_end
        end
      end
    end
  end
end
