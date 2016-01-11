# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of block comments (=begin...=end).
      class BlockComments < Cop
        MSG = 'Do not use block comments.'.freeze
        BEGIN_LENGTH = "=begin\n".length
        END_LENGTH = "\n=end".length

        def investigate(processed_source)
          processed_source.comments.each do |comment|
            add_offense(comment, :expression) if comment.document?
          end
        end

        private

        def autocorrect(comment)
          eq_begin, eq_end, contents = parts(comment)

          lambda do |corrector|
            corrector.remove(eq_begin)
            unless contents.length == 0
              corrector.replace(contents,
                                contents.source
                                  .gsub(/\A/, '# ')
                                  .gsub(/\n\n/, "\n#\n")
                                  .gsub(/\n(?=[^\z#])/, "\n# "))
            end
            corrector.remove(eq_end)
          end
        end

        def parts(comment)
          expr = comment.loc.expression
          eq_begin = expr.resize(BEGIN_LENGTH)
          eq_end = Parser::Source::Range.new(expr.source_buffer,
                                             expr.end_pos - END_LENGTH,
                                             expr.end_pos)
          contents = Parser::Source::Range.new(expr.source_buffer,
                                               eq_begin.end_pos,
                                               eq_end.begin_pos)
          [eq_begin, eq_end, contents]
        end
      end
    end
  end
end
