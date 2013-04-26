# encoding: utf-8

module Rubocop
  module Cop
    class OpMethod < Cop
      ERROR_MESSAGE = 'When defining the %s operator, name its argument other.'

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) do |s|
          if s[1][0] == :@op && !%w([] []= <<).include?(s[1][1])
            if s[2][0] == :paren
              # param is surrounded by braces
              param = s[2][1][1][0]
            else
              param = s[2][1][0]
            end

            unless param[1] == 'other'
              add_offence(:convention,
                          param[2].lineno,
                          sprintf(ERROR_MESSAGE, s[1][1]))
            end
          end
        end
      end
    end
  end
end
