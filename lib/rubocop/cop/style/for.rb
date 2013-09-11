# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of the *for* keyword.
      class For < Cop
        MSG = 'Prefer *each* over *for*.'

        def on_for(node)
          convention(node, :keyword)
        end
      end
    end
  end
end
