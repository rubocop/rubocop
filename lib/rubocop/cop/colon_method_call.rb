# encoding: utf-8

module Rubocop
  module Cop
    class ColonMethodCall < Cop
      ERROR_MESSAGE = 'Do not use :: for method invocation.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:send, sexp) do |s|
          receiver, method_name, *_args = *s

          # discard methods with nil receivers and op methods(like [])
          next unless receiver && method_name =~ /\w/

          if s.src.expression.to_source =~ /::#{method_name}/
            add_offence(:convention,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
