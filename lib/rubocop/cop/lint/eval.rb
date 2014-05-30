# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for the use of *Kernel#eval*.
      class Eval < Cop
        MSG = 'The use of `eval` is a serious security risk.'

        def on_send(node)
          receiver, method_name, = *node

          add_offense(node, :selector) if receiver.nil? && method_name == :eval
        end
      end
    end
  end
end
