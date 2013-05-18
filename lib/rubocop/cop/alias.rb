# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      MSG = 'Use alias_method instead of alias.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:alias, sexp) do |s|
          add_offence(:convention,
                      s.src.keyword.line,
                      MSG)
        end
      end
    end
  end
end
