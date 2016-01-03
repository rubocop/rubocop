# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the use of *Kernel#eval*.
      class Eval < Cop
        MSG = 'The use of `eval` is a serious security risk.'.freeze

        def on_send(node)
          receiver, method_name, *args = *node

          return unless receiver.nil? &&
                        method_name == :eval &&
                        !args.empty? &&
                        args.first.type != :str
          add_offense(node, :selector)
        end
      end
    end
  end
end
