# encoding: utf-8

module Rubocop
  module Cop
    class UnreachableCode < Cop
      MSG = 'Unreachable code detected.'

      NODE_TYPES = [:return, :next, :break, :retry, :redo]
      FLOW_COMMANDS = [:throw, :raise, :fail]

      def on_begin(node)
        expressions = *node

        expressions.each_cons(2) do |e1, e2|
          if NODE_TYPES.include?(e1.type) || flow_command?(e1)
            add_offence(:warning, e2.loc.expression, MSG)
          end
        end

        super
      end

      private

      def flow_command?(node)
        FLOW_COMMANDS.any? { |c| command?(c, node) }
      end
    end
  end
end
