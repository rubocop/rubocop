# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for non-ascii (non-English) characters
      # in comments.
      class AsciiComments < Cop
        MSG = 'Use only ascii symbols in comments.'
        private_constant :MSG

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next if comment.text.ascii_only?
            add_offense(comment, :expression, MSG)
          end
        end
      end
    end
  end
end
