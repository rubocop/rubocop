# encoding: utf-8

module Rubocop
  module Cop
    class Eval < Cop
      ERROR_MESSAGE = 'The use of eval is a serious security risk.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:send, sexp) do |s|
          receiver, method_name = *s

          if receiver.nil? && method_name == :eval
            add_offence(:security,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
