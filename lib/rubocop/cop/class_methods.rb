# encoding: utf-8

module Rubocop
  module Cop
    class ClassMethods < Cop
      ERROR_MESSAGE = 'Prefer self over class/module for class/module methods.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        # defs nodes correspond to class & module methods
        on_node(:defs, sexp) do |s|
          if s.children.first.type == :const
            add_offence(:convention,
                        s.source_map.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
