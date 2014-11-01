# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for comments disabling a cop.
      class DisableCopComment < Cop
        MSG = 'Cop %s disabled on lines %s.'

        def investigate(processed_source)
          comment_config = CommentConfig.new(processed_source)
          processed_source.comments.each do |comment|
            next unless CommentConfig.disable?(comment)

            comment_config.cop_disabled_line_ranges.each do |cop, line_ranges|
              column_range = column_range(comment, cop)
              next unless column_range

              r = source_range(processed_source.buffer, comment.loc.line,
                               column_range)
              line_ranges.each do |disabled_range|
                next unless disabled_range.include?(comment.loc.line)
                add_offense(r, r, format(MSG, cop, disabled_range))
              end
            end
          end
        end

        def column_range(comment, cop)
          cop_name = cop
          column = comment.text.index(cop)
          unless column
            cop_name = File.basename(cop)
            column = comment.text.index(cop_name)
          end
          return nil unless column

          column += comment.loc.column
          column...(column + cop_name.length)
        end
      end
    end
  end
end
