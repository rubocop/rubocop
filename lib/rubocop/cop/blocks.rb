# encoding: utf-8

module Rubocop
  module Cop
    class MultilineBlocks < Cop
      MSG = 'Avoid using {...} for multi-line blocks.'

      def inspect(file, source, tokens, sexp)
        on_node(:block, sexp) do |s|
          if Util.block_length(s) > 0 && s.src.begin.to_source == '{'
            add_offence(:convention, s.src.line, MSG)
          end
        end
      end
    end

    class SingleLineBlocks < Cop
      MSG = 'Prefer {...} over do...end for single-line blocks.'

      def inspect(file, source, tokens, sexp)
        on_node(:block, sexp) do |s|
          if Util.block_length(s) == 0 && s.src.begin.to_source != '{'
            add_offence(:convention, s.src.line, MSG)
          end
        end
      end
    end
  end
end
