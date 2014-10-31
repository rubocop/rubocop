# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for comments disabling a cop.
      class DisableCopComment < Cop
        MSG = 'Do not disable cops with inline comments.'

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            add_offense(comment, :expression) if CommentConfig.disable?(comment)
          end
        end
      end
    end
  end
end
