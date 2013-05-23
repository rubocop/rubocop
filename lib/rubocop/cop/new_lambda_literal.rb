# encoding: utf-8

module Rubocop
  module Cop
    class NewLambdaLiteral < Cop
      MSG = 'Use the new lambda literal syntax ->(params) {...}.'

      TARGET = s(:send, nil, :lambda)

      def on_send(node)
        if node == TARGET && node.src.selector.to_source != '->'
          add_offence(:convention, node.src.line, MSG)
        end

        super
      end
    end
  end
end
