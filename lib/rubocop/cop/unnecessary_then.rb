# encoding: utf-8

module Rubocop
  module Cop
    class UnnecessaryThen < Cop
      ERROR_MESSAGE = 'Never use then for multi-line if/unless.'

      def inspect(file, source, tokens, sexp)
        tokens.each_with_index do |t, ix|
          if t.type == :on_kw && ['if', 'unless'].include?(t.text)
            if multiline_if_then?(tokens, ix + 1)
              index = t.pos.lineno - 1
              add_offence(:convention, index, source[index], ERROR_MESSAGE)
            end
          end
        end
      end

      def multiline_if_then?(tokens, ix)
        then_found = false
        tokens[ix..-1].each do |t|
          case t.type
          when :on_kw
            case t.text
            when 'then' then then_found = true
            when 'end'  then return false
            end
          when :on_ignored_nl, :on_nl
            break
          when :on_comment
            break if t.text =~ /\n/
          when :on_sp
            nil
          else
            then_found = false
          end
        end
        then_found
      end
    end
  end
end
