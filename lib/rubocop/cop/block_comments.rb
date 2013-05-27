# encoding: utf-8

module Rubocop
  module Cop
    class BlockComments < Cop
      MSG = 'Do not use block comments.'

      def on_comment(comment)
        if comment.text.start_with?('=begin')
          add_offence(:convention, comment.pos.line, MSG)
        end
      end
    end
  end
end
