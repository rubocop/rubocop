# encoding: utf-8

module Rubocop
  module Cop
    class Eval < Cop
      ERROR_MESSAGE = 'The use of eval is a serious security risk.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp) do |s|
          sa = s.to_a

          if sa[0].nil? && sa[1] == :eval
            add_offence(:security,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
