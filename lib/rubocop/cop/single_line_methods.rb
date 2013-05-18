# encoding: utf-8

module Rubocop
  module Cop
    class SingleLineMethods < Cop
      MSG = 'Avoid single-line method definitions.'

      def inspect(file, source, tokens, sexp)
        allow_empty = SingleLineMethods.config['AllowIfMethodIsEmpty']

        on_node([:def, :defs], sexp) do |s|
          start_line = s.src.keyword.line
          end_line = s.src.end.line

          if s.type == :def
            empty_body = s.children[2].type == :nil
          else
            empty_body = s.children[3].type == :nil
          end

          if start_line == end_line && !(allow_empty && empty_body)
            add_offence(:convention,
                        start_line,
                        MSG)
          end
        end
      end
    end
  end
end
