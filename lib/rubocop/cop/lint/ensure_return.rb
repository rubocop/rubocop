# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for *return* from an *ensure* block.
      class EnsureReturn < Cop
        MSG = 'Never return from an ensure block.'

        def on_ensure(node)
          _body, ensure_body = *node

          on_node(:return, ensure_body) do |e|
            add_offence(:warning, e.loc.expression, MSG)
          end

          super
        end
      end
    end
  end
end
