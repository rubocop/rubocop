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
      # @example AllowBorderComment: true (default)
      #   # good
      #
      #   def foo
      #   end
      #
      #   #################
      #
      #   def bar
      #   end
      #
      # @example AllowBorderComment: false
      #   # bad
      #
      #   def foo
      #   end
      #
      #   #################
      #
      #   def bar
      #   end
      #
      # @example AllowMarginComment: true (default)
      #   # good
      #
      #   #
      #   # Description of `Foo` class.
      #   #
      #   class Foo
      #   end
      #
      # @example AllowMarginComment: false
      #   # bad
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
          if allow_margin_comment?
            comments = concat_consecutive_comments(processed_source.comments)

            comments.each do |comment|
              next unless empty_comment_only?(comment[0])

              comment[1].each do |offense_comment|
                add_offense(offense_comment)
              end
            end
          else
            processed_source.comments.each do |comment|
              next unless empty_comment_only?(comment_text(comment))

              add_offense(comment)
            end
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            previous_token = previous_token(node)
            range = if previous_token && node.loc.line == previous_token.line
                      range_with_surrounding_space(range: node.loc.expression,
                                                   newlines: false)
                    else
                      range_by_whole_lines(node.loc.expression,
                                           include_final_newline: true)
                    end

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
          empty_comment_pattern = if allow_border_comment?
                                    /\A(#\n)+\z/
                                  else
                                    /\A(#+\n)+\z/
                                  end

          !(comment_text =~ empty_comment_pattern).nil?
        end

        def comment_text(comment)
          "#{comment.text.strip}\n"
        end

        def allow_border_comment?
          cop_config['AllowBorderComment']
        end

        def allow_margin_comment?
          cop_config['AllowMarginComment']
        end

        def current_token(node)
          processed_source.find_token do |token|
            token.pos.column == node.loc.column &&
              token.pos.last_column == node.loc.last_column &&
              token.line == node.loc.line
          end
        end

        def previous_token(node)
          current_token = current_token(node)
          index = processed_source.tokens.index(current_token)
          index.zero? ? nil : processed_source.tokens[index - 1]
        end
      end
    end
  end
end
