# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for calls to debugger or pry.
      class Debugger < Cop
        MSG = 'Remove debugger entry point `%s`.'

        # debugger call node
        #
        # (send nil :debugger)
        DEBUGGER_NODE = s(:send, nil, :debugger)

        # byebug call node
        #
        # (send nil :byebug)
        BYEBUG_NODE = s(:send, nil, :byebug)

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

        # binding.pry_remote node
        #
        # (send
        #   (send nil :binding) :pry_remote)
        PRY_REMOTE_NODE = s(:send, s(:send, nil, :binding), :pry_remote)

        # save_and_open_page
        #
        # (send nil :save_and_open_page)
        CAPYBARA_SAVE_PAGE = s(:send, nil, :save_and_open_page)

        # save_and_open_screenshot
        #
        # (send nil :save_and_open_screenshot)
        CAPYBARA_SAVE_OPEN_SCREENSHOT = s(:send, nil, :save_and_open_screenshot)

        # save_screenshot
        #
        # (send nil :save_screenshot)
        CAPYBARA_SAVE_SCREENSHOT = s(:send, nil, :save_screenshot)

        DEBUGGER_NODES = [
          DEBUGGER_NODE,
          BYEBUG_NODE,
          PRY_NODE,
          REMOTE_PRY_NODE,
          PRY_REMOTE_NODE,
          CAPYBARA_SAVE_PAGE,
          CAPYBARA_SAVE_OPEN_SCREENSHOT,
          CAPYBARA_SAVE_SCREENSHOT
        ]

        def on_send(node)
          receiver, method_name, *_args = *node
          node_without_args = self.class.s(:send, receiver, method_name)
          return unless DEBUGGER_NODES.include? node_without_args
          add_offense(node,
                      :expression,
                      format(MSG, node.loc.expression.source))
        end
      end
    end
  end
end
