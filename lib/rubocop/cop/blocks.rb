# encoding: utf-8

module Rubocop
  module Cop
    class MultilineBlocks < Cop
      ERROR_MESSAGE = 'Avoid using {...} for multi-line blocks.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:block, sexp) do |s|
          if Util.block_length(s) > 0 && s.src.begin.to_source == '{'
            add_offence(:convention, s.src.line, ERROR_MESSAGE)
          end
        end
      end
    end

    class SingleLineBlocks < Cop
      ERROR_MESSAGE = 'Prefer {...} over do...end for single-line blocks.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:block, sexp) do |s|
          if Util.block_length(s) == 0 && s.src.begin.to_source != '{'
            add_offence(:convention, s.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
