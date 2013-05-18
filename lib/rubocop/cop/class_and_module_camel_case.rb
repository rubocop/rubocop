# encoding: utf-8

module Rubocop
  module Cop
    class ClassAndModuleCamelCase < Cop
      MSG = 'Use CamelCase for classes and modules.'

      def inspect(file, source, tokens, sexp)
        on_node([:class, :module], sexp) do |s|
          name = s.src.name.to_source

          add_offence(:convention, s.src.line, MSG) if name =~ /_/
        end
      end
    end
  end
end
