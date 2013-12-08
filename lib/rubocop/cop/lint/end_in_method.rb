# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for END blocks in method definitions.
      class EndInMethod < Cop
        include CheckMethods

        MSG = 'END found in method definition. Use `at_exit` instead.'

        private

        def check(node, *_)
          on_node(:postexe, node) do |end_node|
            add_offence(end_node, :keyword)
          end
        end
      end
    end
  end
end
