# encoding: utf-8

module Rubocop
  module Cop
    class EnsureReturn < Cop
      MSG = 'Never return from an ensure block.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:ensure, sexp) do |ensure_node|
          _body, ensure_body = *ensure_node

          on_node(:return, ensure_body) do |e|
            add_offence(:warning,
                        e.src.line,
                        MSG)
          end
        end
      end
    end
  end
end
