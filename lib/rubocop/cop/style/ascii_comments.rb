# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for non-ascii (non-English) characters
      # in comments.
      class AsciiComments < Cop
        MSG = 'Use only ascii symbols in comments.'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            convention(comment, :expression) if comment.text =~ /[^\x00-\x7f]/
          end
        end
      end
    end
  end
end
