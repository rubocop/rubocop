# encoding: utf-8

module Rubocop
  module Cop
    class BlockComments < Cop
      MSG = 'Do not use block comments.'

      def inspect(source, tokens, ast, comments)
        comments.each do |comment|
          if comment.text.start_with?('=begin')
            add_offence(:convention, comment.loc.line, MSG)
          end
        end
      end
    end
  end
end
