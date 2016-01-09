# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for inline comments.
      class InlineComment < Cop
        MSG = 'Avoid inline comments.'.freeze

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next unless comment.inline?
            add_offense(comment, :expression)
          end
        end
      end
    end
  end
end
