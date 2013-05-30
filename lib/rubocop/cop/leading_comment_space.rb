# encoding: utf-8

module Rubocop
  module Cop
    class LeadingCommentSpace < Cop
      MSG = 'Missing space after #.'

      def inspect(source, tokens, ast, comments)
        comments.each do |comment|
          if comment.text =~ /^#+[^#\s]/
            unless comment.text.start_with?('#!') && comment.loc.line == 1
              add_offence(:convention, comment.loc.line, MSG)
            end
          end
        end
      end
    end
  end
end
