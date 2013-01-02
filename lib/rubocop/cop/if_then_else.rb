# encoding: utf-8

module Rubocop
  module Cop
    class IfThenElse < Cop
      ERROR_MESSAGE =
        ['Never use then for multi-line if/unless.',
         'Favor the ternary operator (?:) over if/then/else/end constructs.',
         'Never use if x; Use the ternary operator instead.']

      def inspect(file, source, tokens, sexp)
        tokens.each_with_index do |t, ix|
          if t.type == :on_kw && ['if', 'unless'].include?(t.text)
            error = case kind_of_if(tokens, ix + 1)
                    when :multiline_if_then then 0
                    when :one_liner         then 1
                    when :semicolon         then 2
                    else                         nil
                    end
            if error
              add_offence(:convention, t.pos.lineno, ERROR_MESSAGE[error])
            end
          end
        end
      end

      def kind_of_if(tokens, ix)
        then_found = false
        tokens[ix..-1].each do |t|
          case t.type
          when :on_kw
            case t.text
            when 'then' then then_found = true
            when 'end'  then return :one_liner
            end
          when :on_ignored_nl, :on_nl
            break
          when :on_semicolon
            return :semicolon
          when :on_comment
            break if t.text =~ /\n/
          when :on_sp
            nil
          else
            then_found = false
          end
        end
        then_found ? :multiline_if_then : nil
      end
    end
  end
end
