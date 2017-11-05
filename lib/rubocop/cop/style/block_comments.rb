# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of block comments (=begin...=end).
      #
      # @example
      #   # bad -
      #   =begin
      #   Multiple lines
      #   of comments...
      #   =end
      #
      #   # good
      #   # Multiple lines
      #   # of comments...
      #
      class BlockComments < Cop
        MSG = 'Do not use block comments.'.freeze
        BEGIN_LENGTH = "=begin\n".length
        END_LENGTH = "\n=end".length

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            next unless comment.document?

            add_offense(comment)
          end
        end

        private

        def autocorrect(comment)
          eq_begin, eq_end, contents = parts(comment)

          lambda do |corrector|
            corrector.remove(eq_begin)
            unless contents.length.zero?
              corrector.replace(contents,
                                contents.source
                                  .gsub(/\A/, '# ')
                                  .gsub(/\n\n/, "\n#\n")
                                  .gsub(/\n(?=[^#])/, "\n# "))
            end
            corrector.remove(eq_end)
          end
        end

        def parts(comment)
          expr = comment.loc.expression
          eq_begin = expr.resize(BEGIN_LENGTH)
          eq_end = range_between(expr.end_pos - END_LENGTH, expr.end_pos)
          contents = range_between(eq_begin.end_pos, eq_end.begin_pos)
          [eq_begin, eq_end, contents]
        end
      end
    end
  end
end
