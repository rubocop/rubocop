# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks whether comments have a leading space after the
      # `#` denoting the start of the comment. The leading space is not
      # required for some RDoc special syntax, like `#++`, `#--`,
      # `#:nodoc`, `=begin`- and `=end` comments, "shebang" directives,
      # or rackup options.
      #
      # @example
      #
      #   # bad
      #   #Some comment
      #
      #   # good
      #   # Some comment
      class LeadingCommentSpace < Cop
        MSG = 'Missing space after `#`.'.freeze

        def investigate(processed_source)
          processed_source.each_comment do |comment|
            next unless comment.text =~ /\A#+[^#\s=:+-]/
            next if comment.loc.line == 1 && allowed_on_first_line?(comment)

            add_offense(comment)
          end
        end

        def autocorrect(comment)
          expr = comment.loc.expression
          hash_mark = range_between(expr.begin_pos, expr.begin_pos + 1)

          ->(corrector) { corrector.insert_after(hash_mark, ' ') }
        end

        private

        def allowed_on_first_line?(comment)
          shebang?(comment) || rackup_config_file? && rackup_options?(comment)
        end

        def shebang?(comment)
          comment.text.start_with?('#!')
        end

        def rackup_options?(comment)
          comment.text.start_with?('#\\')
        end

        def rackup_config_file?
          File.basename(processed_source.buffer.name).eql?('config.ru')
        end
      end
    end
  end
end
