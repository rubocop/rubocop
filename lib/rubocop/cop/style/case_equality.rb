# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of the case equality operator(===).
      class CaseEquality < Cop
        MSG = 'Avoid the use of the case equality operator(===).'

        def on_send(node)
          _receiver, method_name, *_args = *node

          if method_name == :===
            add_offence(:convention, node.loc.selector, MSG)
          end

          super
        end
      end
    end
  end
end
