# encoding: utf-8

module Rubocop
  module Cop
    class AvoidFor < Cop
      ERROR_MESSAGE = 'Prefer *each* over *for*.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:for, sexp) do |s|
          add_offence(:convention,
                      s.src.keyword.line,
                      ERROR_MESSAGE)
        end
      end
    end
  end
end
