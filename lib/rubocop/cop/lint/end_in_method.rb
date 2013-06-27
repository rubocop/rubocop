# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for END blocks in method definitions.
      class EndInMethod < Cop
        MSG = 'END found in method definition. Use `at_exit` instead.'

        def on_def(node)
          check(node)
          super
        end

        def on_defs(node)
          check(node)
          super
        end

        private

        def check(node)
          on_node(:postexe, node) do |end_node|
            add_offence(:warning, end_node.loc.expression, MSG)
          end
        end
      end
    end
  end
end
