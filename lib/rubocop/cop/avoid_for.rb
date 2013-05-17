# encoding: utf-8

module Rubocop
  module Cop
    class AvoidFor < Cop
      MSG = 'Prefer *each* over *for*.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:for, sexp) do |s|
          add_offence(:convention,
                      s.src.keyword.line,
                      MSG)
        end
      end
    end
  end
end
