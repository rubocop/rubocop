# encoding: utf-8

module Rubocop
  module Cop
    class LeadingCommentSpace < Cop
      MSG = 'Missing space after #.'

      def on_comment(c)
        if c.text =~ /^#+[^#\s]/
          unless c.text.start_with?('#!') && c.pos.line == 1
            add_offence(:convention, c.pos.line, MSG)
          end
        end
      end
    end
  end
end
