# encoding: utf-8

module Rubocop
  module Cop
    module IfThenElse
      def inspect(file, source, tokens, sexp)
        tokens.each_with_index do |t, ix|
          if t.type == :on_kw && %w(if unless).include?(t.text)
            if kind_of_if(tokens, ix + 1) == self.class
              add_offence(:convention, t.pos.lineno, error_message)
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
            when 'end'  then return OneLineConditional
            end
          when :on_ignored_nl, :on_nl
            break
          when :on_semicolon
            return IfWithSemicolon
          when :on_comment
            break if t.text =~ /\n/
          when :on_sp
            nil
          else
            then_found = false
          end
        end
        then_found ? MultilineIfThen : nil
      end
    end

    class IfWithSemicolon < Cop
      include IfThenElse
      def error_message
        'Never use if x; Use the ternary operator instead.'
      end
    end

    class MultilineIfThen < Cop
      include IfThenElse
      def error_message
        'Never use then for multi-line if/unless.'
      end
    end

    class OneLineConditional < Cop
      include IfThenElse
      def error_message
        'Favor the ternary operator (?:) over if/then/else/end constructs.'
      end
    end
  end
end
