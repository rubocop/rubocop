# encoding: utf-8

module Rubocop
  module Cop
    class NewLambdaLiteral < Cop
      MSG = 'The new lambda literal syntax is preferred in Ruby 1.9.'

      def inspect(file, source, tokens, ast)
        on_node(:send, ast) do |s|
          if s.to_a == [nil, :lambda] && s.src.selector.to_source != '->'
            add_offence(:convention, s.src.line, MSG)
          end
        end
      end
    end
  end
end
