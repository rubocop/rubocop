# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for trailing inline comments.
      #
      # @example
      #
      #   # good
      #   foo.each do |f|
      #     # Standalone comment
      #     f.bar
      #   end
      #
      #   # bad
      #   foo.each do |f|
      #     f.bar # Trailing inline comment
      #   end
      class InlineComment < Cop
        MSG = 'Avoid trailing inline comments.'.freeze

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next if comment_line?(processed_source[comment.loc.line - 1])
            add_offense(comment, :expression)
          end
        end
      end
    end
  end
end
