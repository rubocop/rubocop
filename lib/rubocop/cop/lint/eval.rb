# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for the use of *Kernel#eval*.
      class Eval < Cop
        MSG = 'The use of eval is a serious security risk.'

        def on_send(node)
          receiver, method_name, = *node

          if receiver.nil? && method_name == :eval
            add_offence(:warning, node.loc.selector, MSG)
          end
        end
      end
    end
  end
end
