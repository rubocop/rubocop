# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses if the keyword *not* instead of !.
      class Not < Cop
        MSG = 'Use ! instead of not.'

        def on_send(node)
          _receiver, method_name, *args = *node

          # not does not take any arguments
          if args.empty? && method_name == :! &&
              node.loc.selector.is?('not')
            add_offence(node, :selector)
          end
        end
      end
    end
  end
end
