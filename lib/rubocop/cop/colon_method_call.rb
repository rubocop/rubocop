# encoding: utf-8

module Rubocop
  module Cop
    class ColonMethodCall < Cop
      ERROR_MESSAGE = 'Do not use :: for method invocation.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp) do |s|
          if s.src.expression.to_source.include?('::')
            add_offence(:convention,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
