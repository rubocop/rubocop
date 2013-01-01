# encoding: utf-8

module Rubocop
  module Cop
    class UnnecessaryThen < Cop
      ERROR_MESSAGE = 'Never use then for multi-line if/unless.'

      def inspect(file, source, tokens, sexp)
        tokens.each_with_index do |t, ix|
          if t[1] == :on_kw && ['if', 'unless'].include?(t[2])
            if multiline_if_then?(tokens, ix + 1)
              index = t[0][0] - 1
              add_offence(:convention, index, source[index], ERROR_MESSAGE)
            end
          end
        end
      end

      def multiline_if_then?(tokens, ix)
        end_found = then_found = false
        tokens[ix..-1].each do |t|
          case t[1]
          when :on_kw
            case t[2]
            when 'then'
              then_found = true
            when 'end'
              end_found = true
              break
            end
          when :on_ignored_nl, :on_nl
            break
          end
        end
        then_found && !end_found
      end
    end
  end
end
