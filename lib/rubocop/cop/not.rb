# encoding: utf-8

module Rubocop
  module Cop
    class Not < Cop
      MSG = 'Use ! instead of not.'

      def inspect(file, source, tokens, ast)
        on_node(:send, ast) do |s|
          _, method_name = *s

          if method_name == :! && s.src.selector.to_source == 'not'
            add_offence(:convention, s.src.line, MSG)
          end
        end
      end
    end
  end
end
