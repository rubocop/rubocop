# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for uses of *begin...end while/until something*.
      class Loop < Cop
        MSG = 'Use Kernel#loop with break rather than ' \
              'begin/end/until(or while).'

        def on_while_post(node)
          register_offence(node)
        end

        def on_until_post(node)
          register_offence(node)
        end

        private

        def register_offence(node)
          add_offence(node, :keyword)
        end
      end
    end
  end
end
