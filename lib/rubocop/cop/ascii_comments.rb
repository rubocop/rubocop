# encoding: utf-8

module Rubocop
  module Cop
    class AsciiComments < Cop
      MSG = 'Use only ascii symbols in comments.'

      def inspect(source, tokens, ast, comments)
        comments.each do |comment|
          if comment.text =~ /[^\x00-\x7f]/
            add_offence(:convention, comment.loc.line, MSG)
          end
        end
      end
    end
  end
end
