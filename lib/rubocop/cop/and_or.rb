# encoding: utf-8

module Rubocop
  module Cop
    class AndOr < Cop
      MSG = 'Use %s instead of %s.'

      OPS = { 'and' => '&&', 'or' => '||' }

      def on_and(node)
        op = node.loc.operator.source
        op_type = node.type.to_s

        if op == op_type
          add_offence(:convention,
                      node.loc.operator.line,
                      sprintf(MSG, OPS[op], op))
        end

        super
      end

      alias_method :on_or, :on_and
    end
  end
end
