# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for unwanted parentheses in parameterless method calls.
      class MethodCallParentheses < Cop
        MSG = 'Do not use parentheses for method calls with no arguments.'

        def on_send(node)
          _receiver, _method_name, *args = *node

          if args.empty? && node.loc.begin
            add_offence(:convention, node.loc.begin, MSG)
          end

          super
        end
      end
    end
  end
end
