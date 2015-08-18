# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for non-ascii (non-English) characters
      # in comments.
      class AsciiComments < Cop
        MSG = 'Use only ascii symbols in comments.'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next if comment.text.ascii_only? ||
                    comment.text !~ /[^\x00-\x7F]{2,}/
            add_offense(comment, :expression)
          end
        end
      end
    end
  end
end
