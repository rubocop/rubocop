# encoding: utf-8

module Rubocop
  module Cop
    class MultilineTernaryOperator < Cop
      def error_message
        'Avoid multi-line ?: (the ternary operator); use if/unless instead.'
      end

      def inspect(file, source, tokens, ast)
        on_node(:if, ast) do |s|
          src = s.src

          # discard non-ternary ops
          next unless src.respond_to?(:question)

          if src.line != src.colon.line
            add_offence(:convention, src.line,
                        error_message)
          end
        end
      end
    end

    class NestedTernaryOperator < Cop
      def error_message
        'Ternary operators must not be nested. Prefer if/else constructs ' +
          'instead.'
      end

      def inspect(file, source, tokens, ast)
        on_node(:if, ast) do |s|
          src = s.src

          # discard non-ternary ops
          next unless src.respond_to?(:question)

          s.children.each do |child|
            on_node(:if, child) do |c|
              add_offence(:convention,
                          c.src.line,
                          error_message) if c.src.respond_to?(:question)
            end
          end
        end
      end
    end
  end
end
