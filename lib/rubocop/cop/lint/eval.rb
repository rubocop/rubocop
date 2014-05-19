# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for the use of *Kernel#eval*.
      class Eval < Cop
        MSG = 'The use of `eval` is a serious security risk.'
        private_constant :MSG

        def on_send(node)
          receiver, method_name, = *node
          return unless receiver.nil? && method_name == :eval

          add_offense(node, :selector, MSG)
        end
      end
    end
  end
end
