module Rubocop
  module Cop
    class Indentation < Cop
      ERROR_MESSAGE = "Indent when as deep as case."

      def inspect(file, source, tokens, sexp)
        case_indentation = nil
        source.each_with_index do |line, index|
          case line
          when /^( *)case\b/ then case_indentation = $1
          when /^( *)when\b/
            if $1 != case_indentation
              add_offence(:convention, index, line, ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
