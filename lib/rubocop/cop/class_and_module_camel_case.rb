# encoding: utf-8

module Rubocop
  module Cop
    class ClassAndModuleCamelCase < Cop
      ERROR_MESSAGE = 'Use CamelCase for classes and modules.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node([:class, :module], sexp) do |s|
          name = s.src.name.to_source

          add_offence(:convention, s.src.line, ERROR_MESSAGE) if name =~ /_/
        end
      end
    end
  end
end
