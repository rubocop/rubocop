# encoding: utf-8

module Rubocop
  module Cop
    class OpMethod < Cop
      ERROR_MESSAGE = 'When defining the %s operator, name its argument other.'

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) do |s|
          if binary_operator?(s) && !%w([] []= <<).include?(s[1][1])
            params = parameters(s[2])
            unless params[0][1] == 'other'
              add_offence(:convention,
                          params[0][2].lineno,
                          sprintf(ERROR_MESSAGE, s[1][1]))
            end
          end
        end
      end

      private

      def binary_operator?(def_sexp)
        def_sexp[1][0] == :@op && parameters(def_sexp[2]).size == 1
      end

      def parameters(param_sexp)
        if param_sexp[0] == :paren # param is surrounded by braces?
          parameters(param_sexp[1])
        else
          param_sexp[1] || []
        end
      end
    end
  end
end
