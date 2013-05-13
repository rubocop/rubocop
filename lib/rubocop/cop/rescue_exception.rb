# encoding: utf-8

module Rubocop
  module Cop
    class RescueException < Cop
      ERROR_MESSAGE = 'Avoid rescuing the Exception class.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:resbody, sexp) do |s|
          rescue_args = s.children.first.children
          if rescue_args.any? { |s| targets_exception?(s) }
            add_offence(:warning,
                        s.src.line,
                        ERROR_MESSAGE)
          end
        end
      end

      def targets_exception?(rescue_arg_sexp)
        return false unless rescue_arg_sexp.type == :const
        children = rescue_arg_sexp.children
        return false unless children[0].nil? || children[0].type == :cbase
        children[1] == :Exception
      end
    end
  end
end
