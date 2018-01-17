# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks empty comment.
      #
      # @example
      #   # bad
      #
      #   #
      #   class Foo
      #   end
      #
      #   # good
      #
      #   #
      #   # Description of `Foo` class.
      #   #
      #   class Foo
      #   end
      #
      class EmptyComment < Cop
        include RangeHelp

        MSG = 'Source code comment is empty.'.freeze

        def investigate(processed_source)
          comments = concat_consecutive_comments(processed_source.comments)

          comments.each do |comment|
            next unless empty_comment_only?(comment[0])

            comment[1].each do |offense_comment|
              add_offense(offense_comment)
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            range = range_by_whole_lines(node.loc.expression,
                                         include_final_newline: true)

            corrector.remove(range)
          end
        end

        private

        def concat_consecutive_comments(comments)
          prev_line = nil

          comments.each_with_object([]) do |comment, concatenated_comments|
            if prev_line && comment.loc.line == prev_line.next
              last_concatenated_comment = concatenated_comments.last

              last_concatenated_comment[0] << comment_text(comment)
              last_concatenated_comment[1] << comment
            else
              concatenated_comments << [comment_text(comment).dup, [comment]]
            end

            prev_line = comment.loc.line
          end
        end

        def empty_comment_only?(comment_text)
          comment_text =~ /\A(#\n)+\z/ ? true : false
        end

        def comment_text(comment)
          "#{comment.text.strip}\n"
        end
      end
    end
  end
end
