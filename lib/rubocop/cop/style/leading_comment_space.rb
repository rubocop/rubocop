# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether comments have a leading space
      # after the # denoting the start of the comment. The
      # leading space is not required for some RDoc special syntax,
      # like #++, #--, #:nodoc, etc. Neither is it required for
      # =begin/=end comments.
      class LeadingCommentSpace < Cop
        MSG = 'Missing space after #.'.freeze

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next unless comment.text =~ /\A#+[^#\s=:+-]/
            next if comment.text.start_with?('#!') && comment.loc.line == 1

            add_offense(comment, :expression)
          end
        end

        def autocorrect(comment)
          expr = comment.loc.expression
          b = expr.begin_pos
          hash_mark = range_between(b, b + 1)
          ->(corrector) { corrector.insert_after(hash_mark, ' ') }
        end
      end
    end
  end
end
