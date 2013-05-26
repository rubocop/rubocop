# encoding: utf-8

module Rubocop
  module Cop
    class TrivialAccessors < Cop
      READER_MESSAGE = 'Use attr_reader to define trivial reader methods.'
      WRITER_MESSAGE = 'Use attr_writer to define trivial writer methods.'

      def inspect(file, source, tokens, ast, comments)
        on_node(:def, ast) do |s|
          _, args, body = *s

          if body.type == :ivar
            add_offence(:convention,
                        s.loc.keyword.line,
                        READER_MESSAGE)
          elsif args.children.size == 1 && body.type == :ivasgn
            add_offence(:convention,
                        s.loc.keyword.line,
                        WRITER_MESSAGE)
          end
        end
      end

    end
  end
end
