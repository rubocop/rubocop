# encoding: utf-8

module Rubocop
  module Cop
    class ClassMethods < Cop
      MSG = 'Prefer self over class/module for class/module methods.'

      def inspect(file, source, tokens, sexp)
        # defs nodes correspond to class & module methods
        on_node(:defs, sexp) do |s|
          if s.children.first.type == :const
            add_offence(:convention,
                        s.src.line,
                        MSG)
          end
        end
      end
    end
  end
end
