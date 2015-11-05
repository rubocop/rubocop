# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for calls to debugger or pry.
      class Debugger < Cop
        MSG = 'Remove debugger entry point `%s`.'

        def_node_matcher :debugger_call?,
                         '{(send nil {:debugger :byebug} ...)
                           (send (send nil :binding)
                             {:pry :remote_pry :pry_remote} ...)
                           (send (const nil :Pry) :rescue ...)
                           (send nil {:save_and_open_page
                                      :save_and_open_screenshot
                                      :save_screenshot} ...)}'

        def on_send(node)
          return unless debugger_call?(node)
          add_offense(node,
                      :expression,
                      format(MSG, node.loc.expression.source))
        end
      end
    end
  end
end
