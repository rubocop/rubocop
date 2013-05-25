# encoding: utf-8

module Rubocop
  module Cop
    class EnsureReturn < Cop
      MSG = 'Never return from an ensure block.'

      def inspect(file, source, tokens, ast)
        on_node(:ensure, ast) do |ensure_node|
          _body, ensure_body = *ensure_node

          on_node(:return, ensure_body) do |e|
            add_offence(:warning,
                        e.loc.line,
                        MSG)
          end
        end
      end
    end
  end
end
