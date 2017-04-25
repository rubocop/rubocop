# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for any empty comments.
      class EmptyComment < Cop
        MSG = 'Empty comment.'.freeze

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            add_offense(comment, :expression) if comment.text.strip == '#'
          end
        end

        def autocorrect(comment)
          # Remove entire line of empty comment (leaves the newline)
          line_no = comment.loc.expression.line
          line_range = comment.loc.expression.source_buffer.line_range(line_no)
          ->(corrector) { corrector.remove(line_range) }
        end
      end
    end
  end
end
