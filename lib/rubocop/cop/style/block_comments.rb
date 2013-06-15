# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class BlockComments < Cop
        MSG = 'Do not use block comments.'

        def inspect(source_buffer, source, tokens, ast, comments)
          comments.each do |comment|
            if comment.text.start_with?('=begin')
              add_offence(:convention, comment.loc, MSG)
            end
          end
        end
      end
    end
  end
end
