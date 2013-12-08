# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for *rescue* blocks with no body.
      class HandleExceptions < Cop
        MSG = 'Do not suppress exceptions.'

        def on_resbody(node)
          _exc_list_node, _exc_var_node, body_node = *node

          add_offence(node, :expression) unless body_node
        end
      end
    end
  end
end
