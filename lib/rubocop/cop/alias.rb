# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      ERROR_MESSAGE = 'Use alias_method instead of alias.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:alias, sexp) do |s|
          add_offence(:convention,
                      s.source_map.keyword.line,
                      ERROR_MESSAGE)
        end
      end
    end
  end
end
