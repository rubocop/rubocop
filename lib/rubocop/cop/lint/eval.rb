# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for the use of *Kernel#eval*.
      class Eval < Cop
        MSG = 'The use of eval is a serious security risk.'

        def on_send(node)
          receiver, method_name, = *node

          add_offence(node, :selector) if receiver.nil? && method_name == :eval
        end
      end
    end
  end
end
