# encoding: utf-8

module Rubocop
  module Cop
    class OpMethod < Cop
      ERROR_MESSAGE = 'When defining binary operators, name the arg other.'

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) do |s|
          if s[1][0] == :@op
            param = s[2][1][1][0]

            puts param.inspect

            unless param[1] == 'other'
              add_offence(:convention,
                          param[2].lineno,
                          ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
