# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for calls to debugger or pry.
      class Debugger < Cop
        MSG = 'Remove calls to debugger.'

        # debugger call node
        #
        # (send nil :debugger)
        DEBUGGER_NODE = s(:send, nil, :debugger)

        # binding.pry node
        #
        # (send
        #   (send nil :binding) :pry)
        PRY_NODE = s(:send, s(:send, nil, :binding), :pry)

        # binding.remote_pry node
        #
        # (send
        #   (send nil :binding) :remote_pry)
        REMOTE_PRY_NODE = s(:send, s(:send, nil, :binding), :remote_pry)

        DEBUGGER_NODES = [DEBUGGER_NODE, PRY_NODE, REMOTE_PRY_NODE]

        def on_send(node)
          add_offence(node, :selector) if DEBUGGER_NODES.include?(node)
        end
      end
    end
  end
end
