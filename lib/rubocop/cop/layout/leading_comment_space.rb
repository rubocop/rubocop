# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
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

            # in config.ru files, if the first line starts with #\ it is treated
            # as options (e.g. `#\ -p 8765` sets the request port to 8765)
            next if comment.text.start_with?('#\\') && comment.loc.line == 1 &&
                    config_ru?(processed_source.buffer.name)

            add_offense(comment, :expression)
          end
        end

        def autocorrect(comment)
          expr = comment.loc.expression
          b = expr.begin_pos
          hash_mark = range_between(b, b + 1)
          ->(corrector) { corrector.insert_after(hash_mark, ' ') }
        end

        private

        def config_ru?(file_path)
          File.basename(file_path).eql?('config.ru')
        end
      end
    end
  end
end
