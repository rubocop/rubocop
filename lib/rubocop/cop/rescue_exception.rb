# encoding: utf-8

module Rubocop
  module Cop
    class RescueException < Cop
      ERROR_MESSAGE = 'Avoid rescuing the Exception class.'

      def inspect(file, source, tokens, sexp)
        each(:rescue, sexp) do |s|
          # TODO Improve handling of rescue One, Two => e
          if valid_case?(s)
            target_class = s[1][0][1][1]

            lineno = s[1][0][1][2].lineno

            add_offence(:warning,
                        lineno,
                        ERROR_MESSAGE) if target_class == 'Exception'
          end
        end
      end

      def valid_case?(s)
        if s[1].nil?
          # rescue with no args
          false
        elsif s[1][0] == :mrhs_new_from_args
          # rescue One, Two => e
          false
        elsif s[1][0][0] == :const_path_ref
          # rescue Module::Class
          false
        elsif s[1][0] == :mrhs_add_star
          # rescue *ERRORS
          false
        else
          true
        end
      end
    end
  end
end
