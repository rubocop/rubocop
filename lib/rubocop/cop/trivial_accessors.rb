# encoding: utf-8

module Rubocop
  module Cop
    class TrivialAccessors < Cop
      READER_MESSAGE = 'Use attr_reader to define trivial reader methods.'
      WRITER_MESSAGE = 'Use attr_writer to define trivial writer methods.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:def, sexp) do |s|
          _, args, body = *s

          if body.type == :ivar
            add_offence(:convention,
                        s.src.keyword.line,
                        READER_MESSAGE)
          elsif args.children.size == 1 && body.type == :ivasgn
            add_offence(:convention,
                        s.src.keyword.line,
                        WRITER_MESSAGE)
          end
        end
      end

    end
  end
end
