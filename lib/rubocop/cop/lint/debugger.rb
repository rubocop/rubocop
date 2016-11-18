# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for calls to debugger or pry.
      class Debugger < Cop
        MSG = 'Remove debugger entry point `%s`.'.freeze

        def_node_matcher :debugger_call?, <<-END
          {(send nil {:debugger :byebug} ...)
           (send (send nil :binding)
             {:pry :remote_pry :pry_remote} ...)
           (send (const nil :Pry) :rescue ...)
           (send nil {:save_and_open_page
                      :save_and_open_screenshot
                      :save_screenshot} ...)}
        END

        def_node_matcher :binding_irb_call?, <<-END
          (send (send nil :binding) :irb ...)
        END

        def_node_matcher :pry_rescue?, '(send (const nil :Pry) :rescue ...)'

        def on_send(node)
          return unless debugger_call?(node) || binding_irb?(node)
          add_offense(node, :expression, format(MSG, node.source))
        end

        def autocorrect(node)
          lambda do |corrector|
            if pry_rescue?(node)
              block = node.parent
              body  = block.children[2] # (block <send> <parameters> <body>)
              corrector.replace(block.source_range, body.source)
            else
              range = node.source_range
              range = range_with_surrounding_space(range, :left, false)
              range = range_with_surrounding_space(range, :right, true)
              corrector.remove(range)
            end
          end
        end

        def binding_irb?(node)
          target_ruby_version >= 2.4 && binding_irb_call?(node)
        end
      end
    end
  end
end
