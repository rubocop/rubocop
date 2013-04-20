# encoding: utf-8

module Rubocop
  module Cop
    class RescueException < Cop
      ERROR_MESSAGE = 'Avoid rescuing the Exception class.'

      def inspect(file, source, tokens, sexp)
        each(:rescue, sexp) do |s|
          # TODO Improve handling of rescue One, Two => e
          unless s[1].nil? || s[1][0] == :mrhs_new_from_args
            target_class = s[1][0][1][1]
            lineno = s[1][0][1][2].lineno

            add_offence(:warning,
                        lineno,
                        ERROR_MESSAGE) if target_class == 'Exception'
          end
        end
      end
    end
  end
end
