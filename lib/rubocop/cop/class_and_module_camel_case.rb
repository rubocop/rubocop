# encoding: utf-8

module Rubocop
  module Cop
    class ClassAndModuleCamelCase < Cop
      ERROR_MESSAGE = 'Use CamelCase for classes and modules.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node([:class, :module], sexp) do |s|
          name = s.src.name.to_source

          if name.split('::').any? { |part| part =~ /_/ }
            add_offence(:convention, s.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
