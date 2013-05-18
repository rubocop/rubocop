# encoding: utf-8

module Rubocop
  module Cop
    class ColonMethodCall < Cop
      MSG = 'Do not use :: for method invocation.'

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp) do |s|
          receiver, method_name, *_args = *s

          # discard methods with nil receivers and op methods(like [])
          next unless receiver && method_name =~ /\w/

          if s.src.expression.to_source =~ /::#{method_name}/
            add_offence(:convention,
                        s.src.line,
                        MSG)
          end
        end
      end
    end
  end
end
