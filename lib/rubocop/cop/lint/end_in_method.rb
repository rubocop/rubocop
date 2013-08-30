# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for END blocks in method definitions.
      class EndInMethod < Cop
        MSG = 'END found in method definition. Use `at_exit` instead.'

        def on_def(node)
          check(node)
        end

        def on_defs(node)
          check(node)
        end

        private

        def check(node)
          on_node(:postexe, node) do |end_node|
            warning(end_node, :keyword)
          end
        end
      end
    end
  end
end
