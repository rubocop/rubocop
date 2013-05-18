# encoding: utf-8

module Rubocop
  module Cop
    class AmpersandsPipesVsAndOr < Cop
      COND_MSG = 'Use &&/|| for conditional expressions.'
      FLOW_MSG = 'Use and/or for flow on control.'

      def inspect(file, source, tokens, sexp)
        on_node([:if, :while, :until], sexp) do |node|
          cond, body = *node

          check_cond(cond)
          check_body(body)
        end

        on_node([:and, :or], sexp, [:if, :while, :until]) do |node|
          check_body(node)
        end
      end

      def check_cond(sexp)
        on_node([:and, :or], sexp) do |sub_sexp|
          if sub_sexp.src.operator.to_source == sub_sexp.type.to_s
            add_offence(:convention,
                        sub_sexp.src.operator.line,
                        COND_MSG)
          end
        end
      end

      def check_body(sexp)
        return unless sexp

        on_node([:and, :or], sexp, [:if, :while, :until]) do |sub_sexp|
          if sub_sexp.src.operator.to_source != sub_sexp.type.to_s
            add_offence(:convention,
                        sub_sexp.src.operator.line,
                        FLOW_MSG)
          end
        end
      end
    end
  end
end
