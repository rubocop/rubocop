# encoding: utf-8

module Rubocop
  module Cop
    class LeadingCommentSpace < Cop
      ERROR_MESSAGE = 'Missing space after #.'

      def inspect(file, source, tokens, sexp)
        tokens.each_index do |ix|
          t = tokens[ix]
          if t.type == :on_comment && t.text =~ /^#+[^#\s]/
            unless t.text.start_with?('#!') && t.pos.lineno == 1
              add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
